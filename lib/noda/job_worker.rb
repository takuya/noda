module Noda

# ジョブワーカー
# 
# ジョブを待ち受けるスレッドです。
# Taskを取りだして実行します．
#   ip=127.0.0.1
#   w=Noda::JobWorker.new("#{ip}", "10001")
#   t = DRb.start_service("druby://#{ip}:10101",w)
#   w.start
# Taskをサーバー経由で送信する
#   ip=127.0.0.1
#   server = Noda::JobServer.new ip,"10001"
#   str = %Q'
#          class Noda::MyTask
#            def do_task(table)
#               table.put @name, "#{Process.pid} : #{Time.now}"
#               return "#{@name} in #{Process.pid} : #{Time.now}"
#            end
#            def initialize(name) @name end
#          end
#   '
#   eval(str)
#   task = Noda::MyTask.new("test")
#   server.add_task_class( task.class.to_s, str)
#   10.times{|i| server.input.push Noda::MyTask.new(i) }
#
class JobWorker
  attr_reader :thread
  attr_accessor :max_retry_connect , :wait_time_to_retry
  # * server_addr ジョブサーバーアドレス、またはホスト名
  # * server_port ジョブサーバーポート
  def initialize( server_addr="localhost",server_port="10001",q="" )
    @server_uri  = "druby://#{server_addr}:#{server_port}"
    @max_retry_connect  = 30
    @wait_time_to_retry =  2
    require "socket" 
    @local_addr = IPSocket::getaddress(Socket::gethostname)
    self.connect
    self
  end
  # 内部的に使います。ジョブサーバーへ接続
  def connect_job_server
    error_conter = 0
    begin 
      @job =DRbObject.new_with_uri(@server_uri)
      @job.hash_table
      @logger = @job.logger
    rescue DRb::DRbConnError => e
      error_conter +=1
      raise e if error_conter > @max_retry_connect
      sleep @wait_time_to_retry 
      retry
    end
  end
  # 担当ジョブからタスクを実行します．
  # 
  # タスクは do_task(hash)実装が必須
  # タスクのクラス定義はrequire必須．（start前にrequire)
  # タスクのクラス定義はサーバー側から自動ロード(eval)します．
  def handle_task()
    # @logger.info("self.class@#{@local_addr}#{self.object_id}"){"i try to pop a task."} 
    task = @job.input.pop
    if task.class ==  DRb::DRbUnknown
      self.load_class(task.name)
      task = task.reload
    end
    result = task.do_task(@job.hash_table)
    @job.output.push result
  end
  # クラス定義をEvalする。クラス定義はサーバーから取り出す．
  # ワーカー側にクラス定義を動的に渡すときに使います．
  # *name クラス名
  def load_class(name)
    s = @job.task_class(name)
    Noda.module_eval(s) if s
  end
  # ワーカーのメインスレッドを起動します．start で使います．
  def init_thread
    @table = @job.hash_table
    @thread= Thread.new{
        loop{
          self.handle_task()
          sleep 0.001
        }
    }
  end

  # サーバーに接続します
  # 
  def connect
    self.connect_job_server
  end

  # 処理を開始します．
  # 
  # threadを返します． worker を起動しっぱなしにするなら thread.joinしてください
  def start
    self.init_thread
    @thread.join
  end

  # ワーカースレッドの状態を取り出します．
  # 
  # マルチスレッドでブロックされてるとsleep になります
  def status
    @thread.status if @thread
  end

  # スレッド停止します．このインスタンスは死にません．start で再起動します．
  def stop
    @thread.kill
  end
end

end
