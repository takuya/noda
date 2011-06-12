# encoding: utf-8
module Noda
#ジョブに登録するタスクのサンプル
#こんな感じでクラスを作って下さい

# タスククラス名は必ずNoda名前空間の下につけます
class Noda::Task
  #this should be overwrite
  def do_task(hash_table)
  end
  #this should be overwrite
  def name
    return self.object_id unless @name
    return @name  if @name
  end
  def name=(str) @name=str end
end


end

