require 'minitest/autorun'
require 'btree'
require 'shoulda'

class TestBtree < MiniTest::Test
  def test_insert_notfull
    t = Btree.create(5)
    t.insert(5, "5")
    assert_equal 1, t.root.size
    assert !t.root.full?
    assert_equal 5, t.degree
    assert_equal 1, t.size
  end
 
  def test_degree_too_small
    assert_raises(RuntimeError) do
      Btree.create(1)
    end
  end

  def test_insert_duplicate_key
    t = Btree.create(2)
    t.insert(1, "1")
    assert_raises(RuntimeError) do
      t.insert(1, "1")
    end
  end

  def test_value_of
    t = Btree.create(5)
    t.insert(1, "foo")
    t.insert(5, "bar")
    t.insert(7, "baz")
    t.insert(3, "findme")
    assert_equal "findme", t.value_of(3)
    assert_equal "baz", t.value_of(7)
    assert_equal "bar", t.value_of(5)
    assert_equal "foo", t.value_of(1)
    assert_nil t.value_of(11)
    assert_equal 4, t.size
    assert_equal ["findme", "bar"], t.value_of(3..6)
  end

  def test_fill_root
    t = Btree.create(2)
    3.times {|n| t.insert(n, n.to_s)}
    assert t.root.full?
    assert_equal [0,1,2], t.root.keys
    assert_equal ['0','1','2'], t.root.values
    assert_equal 3, t.size
  end

  context 'full root' do
    setup do
      @t = Btree.create(2)
      3.times {|n| @t.insert(n*2, n.to_s)}
    end
    should "be able to insert at end" do
      @t.insert(10, "10")
      assert_equal "10", @t.value_of(10)
      assert_equal "0", @t.value_of(0)
      assert_equal "1", @t.value_of(2)
      assert_equal "2", @t.value_of(4)
      assert_equal 4, @t.size
    end
    should "be able to insert at front" do
      @t.insert(-1, "10")
      assert_equal "10", @t.value_of(-1)
      assert_equal "0", @t.value_of(0)
      assert_equal "1", @t.value_of(2)
      assert_equal "2", @t.value_of(4)
      assert_equal 4, @t.size
    end
    should "be able to insert in the middle" do
      @t.insert(3, "10")
      assert_equal "10", @t.value_of(3)
      assert_equal "0", @t.value_of(0)
      assert_equal "1", @t.value_of(2)
      assert_equal "2", @t.value_of(4)
      assert_equal 4, @t.size
    end
    context 'full last child' do 
      setup do
        2.times {|n| @t.insert(n*2 + 10, "foo") }
      end
      should "have full last child" do
        assert @t.root.children.last.full?, "Last child of root should be full"
        assert_equal 5, @t.size
      end
      should "be able to add to end" do
        @t.insert(100, "YEAH!")
        assert_equal "YEAH!", @t.value_of(100)
        assert_equal 6, @t.size
      end
      should "be able to insert many" do
        10.times { |n| @t.insert((n+1) * 100, "YEAH!") }
        assert_equal "YEAH!", @t.value_of(100)
        assert_equal 15, @t.size
      end
    end
    context 'second split of root' do
      setup do
        6.times {|n| @t.insert(n*2 + 10, "foo") }
      end
      should "work" do
        assert_equal 'foo', @t.value_of(10)
        assert_equal 9, @t.size
      end
    end
  end
end
