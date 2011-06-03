# -*- utf8 -*-

module Noda
require 'monitor'
# ジョブのキュー実装
# キューはスレッドセーフに書いている
#
#
class RQueue
  include DRb::DRbUndumped 
  attr_reader :name
  def initialize( max=nil, name=nil )
    @name = name
    @list = []
    @max = nil
    @max = max if max
    self.extend(MonitorMixin)
    @m_empty = self.new_cond
    @m_full = self.new_cond
  end
  def push obj
    self.synchronize{
      @m_full.wait_while{ self.full?  } if @max
      @list.push obj
      @m_empty.broadcast
    }
  end
  def pop
    self.synchronize{
      @m_empty.wait_while{ self.empty?  }
      obj = @list.shift
      @m_full.broadcast if @max
      obj
    }
  end
  def include?(v) @list.include? v        end
  alias exists? include?
  def firsts(n=1) (0...n).map{self.pop}   end
  def first()     self.pop                end
  def size()      @list.size              end
  def max_size()  @max                    end
  def empty?()    @list.empty?            end
  def close_to_full?()    @list.size >= @max-5    end
  def full?()
    # max=nil ならLimitless。つまり無限大
    @list.size >= @max if @max
  end
  def all() self.firsts(self.size) end
  # １からＮまでの値を取る。０始まりでないことに注意
  def _at(pos) 
    i = pos - 1 
    return @list.at(i) if (i) < self.size 
  end
end


end