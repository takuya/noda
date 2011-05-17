require File.dirname(__FILE__) + '/test_helper.rb'

class TestPageList < Test::Unit::TestCase
  def test_table_put
    list = Table.new
    key,value = "test", "valuevalue"
    list.put key,value 
    assert list.get(key) == value
  end
  def test_table_size
    list = Table.new
    key,value = "test", "valuevalue"
    list.put key,value 
    assert list.size == 1
  end
  def test_table_exists
    list = Table.new
    key,value = "test", "valuevalue"
    list.put key,value 
    assert list.exists? key
  end
  def test_table_each
    list = Table.new
    ("a".."e").each_with_index{|v,k| list.put v,k+1 }
    ("a".."e").each_with_index{|v,k| assert(list.get(v)== k+1 ) }
  end
  ##mutexできちんとロックされるか?はテスト必要ないと思う

end
