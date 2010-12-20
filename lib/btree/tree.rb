class Btree::Tree
  attr_reader :root, :degree, :size

  # Creates a BTree of degree 2 by default.  Keys
  # Must support being compared using >, < and == methods.
  def initialize(degree = 2)
    @degree = degree
    @root = Btree::Node.new(@degree)
    @root.leaf = true
    @size = 0
  end

  # Insert a key-value pair into the btree
  def insert(key, value = nil)
    node = @root
    if node.full?  
      @root = Btree::Node.new(@degree)
      @root.leaf = false
      @root.add_child(node)
      @root.split(@root.children.size - 1)
      #puts "After split, root = #{@root.inspect}"
      # split child(@root, 1)
      node = @root
    end
    node.insert(key, value)
    @size += 1
    return self
  end

  # puts internal state
  def dump
    @root.dump
  end

  # Get value associated with the specified key
  def value_of(key)
    @root.value_of(key)
  end

  # Support map like access
  alias_method :"[]", :value_of

  # Support map like key-value setting
  alias_method :"[]=", :insert

end
