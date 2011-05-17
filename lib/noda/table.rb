# 
module Noda
#スレッドセーフなHASHテーブルを作ってる
#内部的にはHashにしている
#KVSとして使っている
#TODO::HASHとして動くようにEnumerableを実装したい
#TODO::DBやファイルに保存する。このクラスAPIでアクセス出来るアダプタを作りたい
class Table
  include DRb::DRbUndumped
  include Enumerable
  attr_reader :name
  def initialize(name=nil)
    @hash = {}
    @name = name
    self.extend(MonitorMixin)
    @m_lock = self.new_cond
  end
  def get(key)
    @hash[key]
  end
  def put(key, obj)
    self.synchronize{
      @hash[key] = obj 
    }
  end
  def has_key?(key) @hash.has_key? key end
  alias :exists? :has_key?
  def keys() @hash.keys end
  def size() @hash.size end
  def each 
    @hash.each_pair{|k,v| yield( k,v )  }
   end
end

end