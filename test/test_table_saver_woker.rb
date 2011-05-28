require File.dirname(__FILE__) + '/test_helper.rb'
Thread.abort_on_exception=true

class TestTableSaverWorker < Test::Unit::TestCase
  def test_table_saver_initialize
    s = JobServer.new("localhost","10001")
    saver = TableAutoSaver.new
    saver.interval = 12
    assert saver.interval == 12
  end
  def test_table_saver_save_dir
    s = JobServer.new("localhost","10002")
    saver = TableAutoSaver.new("localhost","10002")
    begin 
      saver.save_dir = Dir.tmpdir + "a"
    rescue => e
      assert e.to_s =~ %r"is not direcotry."
    end
    d = Dir.mktmpdir("table_saver_")
    saver.save_dir = d
    assert saver.save_dir == d
    Dir.rmdir d
    assert FileTest.exists? d == false
  end
  def test_table_saver_save_dir
    s = JobServer.new("localhost","10003")
    saver = TableAutoSaver.new("localhost","10003")
    t1 = saver.init_thread
    t2 = Thread.new{
      s.hash_table.put("aaaa",1234)
      s.hash_table.put("baaa",1234)
      s.hash_table.put("caaa",1234)
      s.hash_table.put("daaa",1234)
      s.hash_table.put("eaaa",1234)
      while(s.hash_table.has_unsaved_key? )
        sleep 0.001
      end
    }
    
    t2.join
    
    assert s.hash_table.has_unsaved_key? == false
    
  end

end
