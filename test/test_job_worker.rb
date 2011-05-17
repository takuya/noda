require File.dirname(__FILE__) + '/test_helper.rb'
class TestJobWoker < Test::Unit::TestCase


  def test_init_job_woker
    worker = JobWorker.new
    assert worker
  end
  #test task 
  class MyTask
    def do_task(hash)
      return "test_task_end"
    end
  end
  def test_start_stop
    s =JobServer.new
    w = JobWorker.new
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
    s=JobServer.new
    worker = JobWorker.new
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
    s=JobServer.new
    worker = JobWorker.new
    s.input.push MyTask2.new
    worker.handle_task
    ret = s.output.pop
    assert ret == "test_task_end"
    v = s.hash_table.get "MyTask"
    assert v == "foooo"
    s.stop
  end
end
