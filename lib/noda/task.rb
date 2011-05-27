module Noda

class Task
  #QÆ“n‚µ‚É‚µ‚½‚¢‚Æ‚«‚Í ‚±‚Ì include ‚ğg‚¤
  #  objects-by-reference
  #def by_reference() include DRb::DRbUndumped end
  
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

