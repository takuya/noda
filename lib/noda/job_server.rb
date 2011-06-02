module Noda

class JobServer 
  include DRb::DRbUndumped 
  attr_reader :thread, :server
  def initialize( addr='localhost', port='10001',acl=nil,log_file=STDOUT )
    @q_in       = RQueue.new()
    @q_out      = RQueue.new()
    @hash_table = Table.new()
    @server     = DRb.start_service("druby://#{addr}:#{port}",self)
    @thread     = @server.thread
    @logger     = Logger.new(log_file)
    @task_class_source_list = {}
  end
  def stop
    @server.stop_service
  end
  def alive?
    @server.alive?
  end
  def input
    #サーバーは必ずインプットキューを返す
    @q_in
  end
  def output
    @q_out
  end
  def hash_table
    @hash_table
  end
  def start_service
    @thread.join
  end
  def logger
    @logger
  end
  def add_task_class(class_name, source_code)
    @task_class_source_list[class_name] = source_code
  end
  def task_class(class_name)
    @task_class_source_list[class_name]
  end
  def task_class_source_list
    @task_class_source_list
  end
end


end
