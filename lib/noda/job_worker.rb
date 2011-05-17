module Noda


class JobWorker
  attr_reader :thread
  attr_accessor :max_retry_connect , :wait_time_to_retry
  def initialize( job_server_addr="localhost",job_server_port="10001" )
    @server_uri  = "druby://#{job_server_addr}:#{job_server_port}"
    @max_retry_connect  = 30
    @wait_time_to_retry =  2
    self.connect
  end
  def connect_job_server
    error_conter = 0
    begin 
      @job =DRbObject.new_with_uri(@server_uri)
      @job.hash_table
    rescue DRb::DRbConnError => e
      error_conter +=1
      raise e if error_conter > @max_retry_connect
      sleep @wait_time_to_retry 
      retry
    end
  end
  def handle_task()
    task = @job.input.pop
    result = task.do_task(@job.hash_table)
    @job.output.push result
  end
  def init_thread
    @table = @job.hash_table
    @thread= Thread.new {
        loop{
          self.handle_task()
        }
    }
  end
  def connect
    self.connect_job_server
  end
  def start
    self.init_thread
    @thread.join
  end
  def status
    @thread.status
  end
  def stop
    @thread.kill
  end
end


def JobWorker.start_service( job_server_addr="localhost",job_server_port="10001" )
  w=JobWorker.new( job_server_addr,job_server_port)
  w.start
  w
end

end
