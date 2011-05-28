module Noda

class TableAutoSaver < JobWorker
  attr_reader :thread
  attr_accessor :max_retry_connect , :wait_time_to_retry
  def initialize( job_server_addr="localhost",job_server_port="10001" )
    super
    @interval = 2
    require 'tmpdir'
    @save_dir = Dir.tmpdir
  end
  def save_dir=(dirname)
    raise ArgumentError, "#{dirname} is not direcotry." unless FileTest.directory? dirname
    @save_dir=dirname
  end
  def save_dir
    @save_dir
  end
  def handle_task()
    sleep @interval
    return unless @table.has_unsaved_key?
    @table.each_unsaved_pair{|k,v|
      self.save(k,v)
      @table.update_saved_at(k,true)
    }
  end
  def save(key,val)
    Dir.chdir(@save_dir){
      open(key.to_s, "w"){|f|
        f.write(Marshal.dump({:key=>key, :data=>val}))
      }
    }
  end
  def interval=(sec)
    @interval=sec
  end
  def interval()
    @interval
  end
end


end