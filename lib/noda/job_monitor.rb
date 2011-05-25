
module Noda

class JobMonitor
  require 'webrick'
  require 'drb/drb'
  attr_accessor :job_server, :web_server
  def initialize(addr="localhost",port="10080",job_server="druby://localhost:10001")
    @job_server = DRbObject.new_with_uri(job_server)
    @addr = addr
    @port = port
    self.init_webrick
  end
  def start_monitor
    trap("INT"){ @web_server.shutdown }
    @thread = Thread.new{ @web_server.start} 
  end
  def stop_monitor
    @web_server.stop
  end
  def init_webrick
    config = WEBrick::Config::HTTP
    config[:Port] = @port
    config[:BindAddress]=@addr
    config[:AccessLog] = WEBrick::Log.new("/dev/null",1)    #ログ要らない．
    config[:Logger] = Logger.new("/dev/null")    #ログ要らない．
    @web_server = WEBrick::HTTPServer.new(config)
    @web_server.mount_proc '/' do |req,res|
      res.content_type="text/plain"
      res.body = "running" if @job_server.alive?
      res.body = "stopped" unless @job_server.alive?
    end
    @web_server.mount_proc '/in_queue' do |req,res|
      res.content_type="text/plain"
      if req.path_info =~ %r'^/(\d+)$' then
        num = $1.to_i
        res.body = @job_server.input._at(num).to_s
      end
      if req.path_info =~ %r'^/$' then
       res.body = @job_server.input.size.to_s
      end
    end
    @web_server.mount_proc '/out_queue' do |req,res|
      res.content_type="text/plain"
      if req.path_info =~ %r'^/(\d+)$' then
        num = $1.to_i
        res.body = @job_server.output._at(num).to_s
      end
      if req.path_info =~ %r'^/$' then
        res.body = @job_server.output.size.to_s
      end
    end
    @web_server.mount_proc '/hash_table' do |req,res|
      res.content_type="text/plain"
      res.body = @job_server.hash_table.size.to_s
    end
    @web_server.mount_proc '/hash_table/keys' do |req,res|
      res.content_type="text/plain"
      res.body = @job_server.hash_table.keys.inspect
    end
    @web_server.mount_proc '/hash_table/fetch' do |req,res|
      res.content_type="text/plain"
      if req.path_info =~ %r'^/([^/]+)$' then
        key = $1.to_s
        res.body = @job_server.hash_table.get(key).to_s
      end
    end
  end
end

end
