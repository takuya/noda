module Noda

# ==ジョブサーバを表すクラス.
# ===ジョブサーバー
# +ジョブサーバー
# ++ポート+アドレス
# ++インプット・キュー
# ++アウトプット・キュー
# ++ハッシュテーブル
# で構成される
# == ジョブサーバーの起動
#    noda_job_server start
# == ジョブサーバーにタスクを登録
#   require 'drb'
#   sever = DRbObject.new_with_uri('druby://localhost:10001')
#   # タスククラス定義をサーバーに保存して共有する
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
#   server.add_task_class( task.class.to_s, str)
#   # 登録
#   task = Noda::MyTask.new("test")
#   server.input.push task
#    
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
  # input queue. 
  # +return Noda::RQueue 
  def input
    #サーバーは必ずインプットキューを返す
    @q_in
  end
  # output . Noda::RQueue 
  # +return Noda::RQueue 
  def output
    @q_out
  end
  # タスク間で共有するハッシュテーブル Noda::Table
  # +return Noda::Table
  def hash_table
    @hash_table
  end
  def start_service
    @thread.join
  end
  # ジョブのロガーを指定する．
  def logger
    @logger
  end
  # タスクのクラス定義。ワーカーにクラス定義を送信する。
  # 
  #
  def add_task_class(class_name, source_code)
    @task_class_source_list[class_name] = source_code
  end
  # タスクのクラス定義を取り出す．
  def task_class(class_name)
    @task_class_source_list[class_name]
  end
  # 登録したクラス定義一覧を取り出す．
  def task_class_source_list
    @task_class_source_list
  end
end


end
