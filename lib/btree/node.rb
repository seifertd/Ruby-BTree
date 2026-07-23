class Btree::Node
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
    i = 0
    i += 1 while i < size && lo && @keys[i].first < lo

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

    i = 1
    while i <= size && key > @keys[i-1].first
      i += 1
    end

    #puts "Getting value of key #{key}, i = #{i}, keys = #{@keys.inspect}, leaf? #{leaf?}, numchildren: #{@children.size}"

    if i <= size && key == @keys[i-1].first
      #puts "Found key: #{key.inspect}"
      return @keys[i-1].last
    elsif leaf?
      #puts "We are a leaf, no more children, so val is nil"
      return nil
    else
      #puts "Looking into child #{i}"
      return @children[i-1].value_of(key)
    end
  end

  def insert(key, value)
    i = size - 1
    #puts "INSERTING #{key} INTO NODE: #{self.inspect}"
    if leaf?
      raise "Duplicate key" if @keys.any?{|(k,v)| k == key }  #OPTIMIZE: This is inefficient
      while i >= 0 && @keys[i] && key < @keys[i].first
        @keys[i+1] = @keys[i]
        i -= 1
      end
      @keys[i+1] = [key, value]
    else
      while i >= 0 && @keys[i] &&  key < @keys[i].first
        i -= 1
      end
      #puts "   -- INSERT KEY INDEX #{i}"
      if @children[i+1] && @children[i+1].full?
        split(i+1)
        if key > @keys[i+1].first
          i += 1
        end
      end
      @children[i+1].insert(key, value)
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

end
