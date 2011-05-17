require File.dirname(__FILE__) + '/test_helper.rb'


class TestJobServer < Test::Unit::TestCase
  def test_start_stop_job_server
    #�W���u�}�X�^���N�����邩�ǂ���
    s = JobServer.new
    assert s.alive? == true
    s.stop
    assert s.alive? == false
  end
  def test_job_server_input_queue
    #druby�o�R�Ő������u���b�N����邩�ǂ���
    test_str = "hello world"
    s=JobServer.new
    m =  m = DRbObject.new_with_uri('druby://localhost:10001')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10001')
      q1 = m1.input
      q1.pop
      
    }
    #�u���b�N����Ă��邩
    assert t1.status == "sleep"
    m2 = DRbObject.new_with_uri('druby://localhost:10001')
    q2 = m2.input
    q2.push test_str
    #�u���b�N��������ꂩ�ǂ���
    assert t1.status == "run"
    #�T�[�o�[���~
    s.stop
  end
  def test_job_server_output_queue
    #druby�o�R�Ő������u���b�N����邩�ǂ���
    test_str = "hello world"
    s=JobServer.new
    m =  m = DRbObject.new_with_uri('druby://localhost:10001')
    t1 = Thread.new{
      m1 = DRbObject.new_with_uri('druby://localhost:10001')
      q1 = m1.output
      q1.pop
      
    }
    #�u���b�N����Ă��邩
    assert t1.status == "sleep"
    m2 = DRbObject.new_with_uri('druby://localhost:10001')
    q2 = m2.output
    q2.push test_str
    #�u���b�N��������ꂩ�ǂ���
    assert t1.status == "run"
    #�T�[�o�[���~
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

