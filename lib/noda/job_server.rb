module Noda

# ==�W���u�T�[�o��\���N���X.
# ===�W���u�T�[�o�[
# +�W���u�T�[�o�[
# ++�|�[�g+�A�h���X
# ++�C���v�b�g�E�L���[
# ++�A�E�g�v�b�g�E�L���[
# ++�n�b�V���e�[�u��
# �ō\�������
# == �W���u�T�[�o�[�̋N��
#    noda_job_server start
# == �W���u�T�[�o�[�Ƀ^�X�N��o�^
#   require 'drb'
#   sever = DRbObject.new_with_uri('druby://localhost:10001')
#   # �^�X�N�N���X��`���T�[�o�[�ɕۑ����ċ��L����
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
#   # �o�^
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
    #�T�[�o�[�͕K���C���v�b�g�L���[��Ԃ�
    @q_in
  end
  # output . Noda::RQueue 
  # +return Noda::RQueue 
  def output
    @q_out
  end
  # �^�X�N�Ԃŋ��L����n�b�V���e�[�u�� Noda::Table
  # +return Noda::Table
  def hash_table
    @hash_table
  end
  def start_service
    @thread.join
  end
  # �W���u�̃��K�[���w�肷��D
  def logger
    @logger
  end
  # �^�X�N�̃N���X��`�B���[�J�[�ɃN���X��`�𑗐M����B
  # 
  #
  def add_task_class(class_name, source_code)
    @task_class_source_list[class_name] = source_code
  end
  # �^�X�N�̃N���X��`�����o���D
  def task_class(class_name)
    @task_class_source_list[class_name]
  end
  # �o�^�����N���X��`�ꗗ�����o���D
  def task_class_source_list
    @task_class_source_list
  end
end


end
