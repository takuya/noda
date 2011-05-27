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
    assert list.size == 0
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
    data = { "a"=> "aa","b"=>"bv", "c"=> "cc", "d"=> "dd" }
    data.each{|k,v| list.put k,v }
    data.each{|k,v| assert list.get(k) == v }
    list.each{|k,v| assert data[k] == v }
  end
  def test_save_table_data
    list = Table.new
    key,value = "test", "valuevalue"
    list.put key,value 
    assert list.saved?(key) == false
    list.update_saved_at(key)
    assert list.saved?(key) == true
  end
  def test_table_each_unsaved_pair
    list = Table.new
    data = { "a"=> "aa","b"=>"bb", "c"=> "cc", "d"=> "dd" }
    data.each{|k,v| list.put k,v }
    list.put( "abc","123")
    list.update_saved_at("abc")
    assert list.saved?("abc")
    a={}
    list.each_unsaved_pair{|k,v|  a[k]=v }
    assert a.sort == data.sort
  end

end
