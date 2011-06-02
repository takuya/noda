require File.dirname(__FILE__) + '/test_helper.rb'
class TestJobWoker < Test::Unit::TestCase


  def test_init_job_woker
    s=JobServer.new("localhost", "10001")
    worker = JobWorker.new("localhost", "10001")
    assert worker
  end
  #test task 
  class MyTask
    def do_task(hash)
      return "test_task_end"
    end
  end
  def test_start_stop
    s=JobServer.new("localhost", "10002")
    w = JobWorker.new("localhost", "10002")
    t = Thread.new{
      w.start
    }
    s.input.push MyTask.new
    ret = s.output.pop
    assert ret == "test_task_end"
    s.stop
    w.stop
    assert w.status == false #スレッド終了できた？
  end
  def test_do_task
    s=JobServer.new("localhost", "10003")
    worker = JobWorker.new("localhost", "10003")
    s.input.push MyTask.new
    worker.handle_task
    ret = s.output.pop
    assert ret == "test_task_end"
    s.stop
  end
  class MyTask2
    def do_task(hash)
      hash.put "MyTask", "foooo"
      return "test_task_end"
    end
  end
  def test_task_write_hash_table
    #ジョブサーバーの共有領域に書き込めるかどうか
    s=JobServer.new("localhost", "10004")
    worker = JobWorker.new("localhost", "10004")
    s.input.push MyTask2.new
    worker.handle_task
    ret = s.output.pop
    assert ret == "test_task_end"
    v = s.hash_table.get "MyTask"
    assert v == "foooo"
    s.stop
  end
  def test_task_class_load
    s=JobServer.new("localhost", "10005")
    worker = JobWorker.new("localhost", "10005")
    str = "class MyTaskTime\n
    attr_accessor :name
    def initialize(name)
      @name = name
    end
    def do_task(hash)
      return self.name+1.to_s
    end
    end
    "
    s.add_task_class("MyTaskTime",str)
    eval(str)
    s.input.push MyTaskTime.new("test_task")
    worker.handle_task
    ret = s.output.pop
    assert ret == "test_task1"
  end
end
