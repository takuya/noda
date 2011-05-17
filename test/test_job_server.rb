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
    s=JobServer.new
    m =  m = DRbObject.new_with_uri('druby://localhost:10001')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10001')
      q1 = m1.input
      q1.pop
      
    }
    #ブロックされているか
    assert t1.status == "sleep"
    m2 = DRbObject.new_with_uri('druby://localhost:10001')
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
    s=JobServer.new
    m =  m = DRbObject.new_with_uri('druby://localhost:10001')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10001')
      q1 = m1.output
      q1.pop
      
    }
    #ブロックされているか
    assert t1.status == "sleep"
    m2 = DRbObject.new_with_uri('druby://localhost:10001')
    q2 = m2.output
    q2.push test_str
    #ブロックが解放されかどうか
    assert t1.status == "run"
    #サーバーを停止
    s.stop
  end
  def test_job_server_input_queue_data
    s=JobServer.new
    m =  m = DRbObject.new_with_uri('druby://localhost:10001')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10001')
      q1 = m1.input
      q1.push "hello world"
      
    }
    m2 = DRbObject.new_with_uri('druby://localhost:10001')
    q2 = m2.input
    ret = q2.pop
    assert ret == "hello world"
    s.stop
  end
  def test_job_server_output_queue_data
    s=JobServer.new
    m =  m = DRbObject.new_with_uri('druby://localhost:10001')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10001')
      q1 = m1.output
      q1.push "hello world"
      
    }
    m2 = DRbObject.new_with_uri('druby://localhost:10001')
    q2 = m2.output
    ret = q2.pop
    assert ret == "hello world"
    s.stop
  end
end

