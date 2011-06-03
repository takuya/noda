# -*- utf8 -*-

module Noda
require 'monitor'
# ジョブのキュー実装
# キューはスレッドセーフに書いている
# 
# キューから値を取り出すと、キューには残らない。
# ==使用法
#     require 'noda'
#     server =Noda::JobServer.new
#     q = server.input #<= Jobサーバーが持ってる
#     q.push Noda::MyTask.new("hogehgoe")
#
class RQueue
  include DRb::DRbUndumped 
  attr_reader :name
  # 
  def initialize( max=nil, name=nil )
    @name = name
    @list = []
    @max = nil
    @max = max if max
    self.extend(MonitorMixin)
    @m_empty = self.new_cond
    @m_full = self.new_cond
  end
  # キュー末尾にオブジェクトを追加。
  #
  # キュー満杯時は実行スレッドをWaitさせます。
  def push obj
    self.synchronize{
      @m_full.wait_while{ self.full?  } if @max
      @list.push obj
      @m_empty.broadcast
    }
  end
  # キュー先頭からオブジェクトを取り出す．
  #
  # キュー空なら実行スレッドをWaitさせる．
  def pop
    self.synchronize{
      @m_empty.wait_while{ self.empty?  }
      obj = @list.shift
      @m_full.broadcast if @max
      obj
    }
  end
  # 実験用メソッド・使わない．
  def include?(v) @list.include? v        end
  alias exists? include?
  # キューの先頭N個を取り出す．
  def firsts(n=1) (0...n).map{self.pop}   end
  # キューの先頭１個を取り出す． pop の別名
  def first()     self.pop                end
  # キューのサイズを取得
  def size()      @list.size              end
  # キュー格納可能数
  def max_size()  @max                    end
  # キューに値があるか
  def empty?()    @list.empty?            end
  # キュー満杯が近いときにTrueを返す．
  def close_to_full?()    @list.size >= @max-5    end
  # キューが満杯かどうか
  def full?()
    # max=nil ならLimitless。つまり無限大
    @list.size >= @max if @max
  end
  # キューの値全てを取り出す．
  def all() self.firsts(self.size) end
  # キューの先頭N番目の値を調べる．チェック用。
  # - pos １からＮまでの値を取る。先頭は1 で指定する．０始まりでないことに注意
  def _at(pos) 
    i = pos - 1 
    return @list.at(i) if (i) < self.size 
  end
end


end