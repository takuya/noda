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
    @saved_keys = []
  end
  def get(key)
    @hash[key][:data]
  end
  def put(key, obj)
    self.synchronize{
      @hash[key] = {:data=>obj,:saved=>false}
    }
  end
  def has_key?(key) @hash.has_key? key end
  alias :exists? :has_key?
  def keys() @hash.keys end
  def size() @hash.size end
  def each 
    @hash.each_pair{|k,v| yield( k,v[:data] )  }
    nil
  end
  def saved?(key)
    @hash[key][:saved]
  end
  def update_saved_at(key,status=true)
    self.synchronize{
      @hash[key][:saved]=status
    }
  end
  def each_unsaved_pair
    @hash.each_pair{|k,v| next if v[:saved]; yield( k, v[:data] )  }
    nil
  end
  def has_unsaved_key?
    return true if @hash.find{|k,v| v[:saved]==false}
    return false
  end
end

end

