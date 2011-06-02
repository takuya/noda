require File.dirname(__FILE__) + '/test_helper.rb'


class TestJobServer < Test::Unit::TestCase
  def test_start_stop_job_server
    #ジョブマスタが起動するかどうか
    s = JobServer.new
    assert s.alive? == true
    s.stop
    assert s.alive? == false
  end
  def test_job_server_input_queue
    #druby経由で正しくブロックされるかどうか
    test_str = "hello world"
    s=JobServer.new("localhost", "10002")
    m =  m = DRbObject.new_with_uri('druby://localhost:10002')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10002')
      q1 = m1.input
      q1.pop
      
    }
    #ブロックされているか
    assert t1.status == "sleep"
    m2 = DRbObject.new_with_uri('druby://localhost:10002')
    q2 = m2.input
    q2.push test_str
    #ブロックが解放されかどうか
    assert t1.status == "run"
    #サーバーを停止
    s.stop
  end
  def test_job_server_output_queue
    #druby経由で正しくブロックされるかどうか
    test_str = "hello world"
    s=JobServer.new("localhost", "10003")
    m =  m = DRbObject.new_with_uri('druby://localhost:10003')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10003')
      q1 = m1.output
      q1.pop
      
    }
    #ブロックされているか
    assert t1.status == "sleep"
    m2 = DRbObject.new_with_uri('druby://localhost:10003')
    q2 = m2.output
    q2.push test_str
    #ブロックが解放されかどうか
    assert t1.status == "run"
    #サーバーを停止
    s.stop
  end
  def test_job_server_input_queue_data
    s=JobServer.new("localhost", "10004")
    m =  m = DRbObject.new_with_uri('druby://localhost:10004')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10004')
      q1 = m1.input
      q1.push "hello world"
      
    }
    m2 = DRbObject.new_with_uri('druby://localhost:10004')
    q2 = m2.input
    ret = q2.pop
    assert ret == "hello world"
    s.stop
  end
  def test_job_server_output_queue_data
    s=JobServer.new("localhost", "10005")
    m =  m = DRbObject.new_with_uri('druby://localhost:10005')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10005')
      q1 = m1.output
      q1.push "hello world"
      
    }
    m2 = DRbObject.new_with_uri('druby://localhost:10005')
    q2 = m2.output
    ret = q2.pop
    assert ret == "hello world"
    s.stop
  end
  def test_job_server_add_class_source_code
    s=JobServer.new("localhost", "10006")
    str1  = "class MyTestUnitTask\n end"
    s.add_task_class("MyTestUnitTask", str1)
    str2 = s.task_class("MyTestUnitTask")
    assert str1 == str1
    e = nil
    begin 
      t = MyTestUnitTask.class
      rescue NameError => e 
      ensure 
        assert e !=nil
    end
    eval(str2)
    assert MyTestUnitTask.class == Class
    
    m1 = DRbObject.new_with_uri('druby://localhost:10006')
    str3 = m1.task_class("MyTestUnitTask")
    assert str1 == str3
    s.stop
  end
end


