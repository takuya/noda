module Noda

class Task
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

