require File.dirname(__FILE__) + '/test_helper.rb'

class TestPageList < Test::Unit::TestCase
  def test_task_name
    t = Task.new
    assert t.name == t.object_id
    t.name = "No.001"
    assert t.name == "No.001"
  end
end
