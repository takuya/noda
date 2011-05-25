require File.dirname(__FILE__) + '/test_helper.rb'
class TestJobMonitor < Test::Unit::TestCase
  #テストはマルチスレッドで行われるので、ポート衝突してErrorになります．
  def test_start_monitor
    #モニタが起動するかどうか
    m = JobMonitor.new("localhost","10081")
    t = m.start_monitor
    sleep 0.01
    assert m.web_server.status == :Running
    m.stop_monitor
    sleep 0.01
    assert m.web_server.status == :Shutdown
  end
  def test_monitor_in_queue
    require 'open-uri'
    
    m = JobMonitor.new("localhost", "10080")
    t = m.start_monitor
    sleep 0.01
    assert m.web_server.status == :Running
    s = JobServer.new
    s.input.push 1234
    assert open("http://localhost:10080/").read  == "running"
    assert open("http://localhost:10080/in_queue/").read == "1"
    s.input.push 1111
    assert open("http://localhost:10080/in_queue/").read == "2"
    assert open("http://localhost:10080/in_queue/1").read == "1234"
    assert open("http://localhost:10080/in_queue/2").read == "1111"
    d = s.input.pop
    assert open("http://localhost:10080/in_queue/").read == "1"
  end
  def test_monitor_out_queue
    require 'open-uri'
    
    s = JobServer.new("localhost","100011")
    m = JobMonitor.new("localhost", "10083","druby://localhost:100011")
    t = m.start_monitor
    sleep 0.01
    assert m.web_server.status == :Running
    s.output.push 1234
    assert open("http://localhost:10083/").read  == "running"
    assert open("http://localhost:10083/out_queue/").read == "1"
    s.output.push 1111
    assert open("http://localhost:10083/out_queue/").read == "2"
    assert open("http://localhost:10083/out_queue/1").read == "1234"
    assert open("http://localhost:10083/out_queue/2").read == "1111"
  end
  def test_monitor_in_queue
    require 'open-uri'
    
    s = JobServer.new("localhost","100012")
    m = JobMonitor.new("localhost", "10084","druby://localhost:100012")
    t = m.start_monitor
    sleep 0.01
    assert m.web_server.status == :Running
    assert open("http://localhost:10084/").read  == "running"
    assert open("http://localhost:10084/hash_table/").read == "0"
    s.hash_table.put "1234", "abcdefg"
    assert open("http://localhost:10084/hash_table/").read == "1"
    assert open("http://localhost:10084/hash_table/fetch/1234").read  == "abcdefg"
    assert open("http://localhost:10084/hash_table/keys").read == "[\"1234\"]"
  end
end
