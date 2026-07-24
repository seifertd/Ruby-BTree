class Btree::Node

  # Nodes holding at most this many keys are searched by a straight scan
  # rather than by bsearch, whose per-probe block dispatch costs more than the
  # comparisons it saves on a short array.  The measured crossover is around
  # 23 keys and the curves are within a couple of percent of each other from
  # roughly 19 to 23, so the exact value here matters little.  Note that a
  # degree of 12 or less can never exceed the limit (a node holds at most
  # 2*degree - 1 keys), and that a node under a larger degree still scans
  # while it is sparsely filled.
  LINEAR_SCAN_LIMIT = 20
  private_constant :LINEAR_SCAN_LIMIT

  def initialize(degree)
    @degree = degree
    @keys = []
    @children = []
  end

  def dump(level = 0)
    @keys.each_with_index do |key, idx|
      puts "LEVEL: #{level} => #{key.first}: full? #{full?} leaf? #{leaf?} children: #{values.inspect}"
      if @children[idx]
         @children[idx].dump(level + 1)
      end
    end
    (@children[@keys.size..-1] || []).each do |c|
      c.dump(level+1)
    end
    nil
  end

  def add_child(node)
    @children << node
  end

  def children
    @children.dup.freeze
  end

  def keys
    @keys.map(&:first).freeze
  end

  def values
    @keys.map(&:last).freeze
  end

  def full?
    size >= 2 * @degree - 1
  end

  def leaf?
    @children.length == 0
  end

  def size
    @keys.size
  end

  # Values whose keys fall in the range, in key order.  Subtrees that cannot
  # contain an in-range key are never visited.
  def values_of(range)

    result = Array.new
    lo = range.begin
    hi = range.end

    # Skip the keys, and the subtrees between them, that sort entirely below
    # the range.  When every key is below it, this lands on the rightmost
    # child, which may still hold in-range keys.
    i = lo ? key_index(lo) : 0

    result += @children[i].values_of(range) if !leaf? && @children[i]

    while i < size
      key = @keys[i].first
      # Everything from here on sorts above the range.
      break if hi && (range.exclude_end? ? key >= hi : key > hi)
      result << @keys[i].last if range.cover? key
      result += @children[i+1].values_of(range) if !leaf? && @children[i+1]
      i += 1
    end

    result

  end


  def value_of(key)

    return values_of(key) if key.kind_of? Range

    i = key_index(key)

    if i < size && key == @keys[i].first
      return @keys[i].last
    elsif leaf?
      return nil
    else
      return @children[i].value_of(key)
    end
  end

  def insert(key, value)
    # The slot the key would occupy is also the slot it would already occupy if
    # it were present, so locating it and rejecting a duplicate are one step.
    # Checked at every node on the way down, not just at the leaf: a key that a
    # split has promoted into an internal node would otherwise be descended
    # past and inserted a second time, hiding one copy in a subtree.
    i = key_index(key)
    raise "Duplicate key" if i < size && @keys[i].first == key

    if leaf?
      @keys.insert(i, [key, value])
    else
      if @children[i] && @children[i].full?
        split(i)
        # The split just promoted a key into this node, after the check above.
        raise "Duplicate key" if @keys[i].first == key
        i += 1 if key > @keys[i].first
      end
      @children[i].insert(key, value)
    end
  end

  def split(child_idx)
    raise "Invalid child index #{child_idx} in split, num_children = #{@children.size}" if child_idx < 0 || child_idx >= @children.size
    #puts "SPLIT1: #{self.inspect}"
    splitee = @children[child_idx]
    y = Btree::Node.new(@degree)
    z = Btree::Node.new(@degree)
    (@degree-1).times do |j|
      z._keys[j] = splitee._keys[j+@degree]
      y._keys[j] = splitee._keys[j]
    end
    if !splitee.leaf?
      @degree.times do |j|
        z._children[j] = splitee._children[j+@degree]
        y._children[j] = splitee._children[j]
      end
    end
    mid_val = splitee._keys[@degree-1]
    #puts "SPLIT2: #{self.inspect}"
    (@keys.size).downto(child_idx) do |j|
      @children[j+1] = @children[j]
    end

    @children[child_idx+1] = z
    @children[child_idx] = y
    
    #puts "SPLIT3: #{self.inspect}"

    (@keys.size - 1).downto(child_idx) do |j|
      @keys[j+1] = @keys[j]
    end

    #puts "SPLIT4: #{self.inspect}"

    @keys[child_idx] = mid_val
    #puts "SPLIT5: #{self.inspect}"
  end

  protected

  def _keys
    @keys
  end

  def _children
    @children
  end

  private

  # Index of the first key that does not sort below the given one, or size if
  # every key sorts below it.  For an internal node that is also the index of
  # the child to descend into.  Both branches test only < so that keys need
  # only support <, > and == -- bsearch's natural k >= key would widen that.
  def key_index(key)
    n = size
    if n <= LINEAR_SCAN_LIMIT
      i = 0
      i += 1 while i < n && @keys[i].first < key
      i
    else
      @keys.bsearch_index {|(k, _)| !(k < key) } || n
    end
  end

end
