require File.dirname(__FILE__) + '/test_helper.rb'

class TestRQueue < Test::Unit::TestCase
  def setup
    @q = RQueue.new
  end
  def test_RQueue_init
    q = RQueue.new
    assert q.empty?
  end
  def test_RQueue_init_with_RQueue_max_size
    max = 10
    q = RQueue.new max
    assert q.empty? && q.max_size==max
  end
  def test_RQueue_mutex_push
    max = 100
    q = RQueue.new max
    th1 = Thread.new{
      loop{
        q.push 1
      }
    }
    th2 = Thread.new{
      loop{
        q.push 1
      }
    }
    sleep 0.1
    assert th1.status == "sleep" && th2.status == "sleep" && q.full?
  end
  def test_RQueue_mutex_pop
    max = 10
    q = RQueue.new max
    max.times{ q.push 1 }
    th1 = Thread.new{
      loop{
        q.pop
      }
    }
    th2 = Thread.new{
      loop{
        q.pop
      }
    }
    while not q.empty? do
      sleep 0.1
    end
    assert th1.status == "sleep" && th2.status == "sleep" && q.empty?
  end
end
