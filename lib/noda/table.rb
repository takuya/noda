# encoding: utf-8
# 
module Noda
#  スレッドセーフなHASHテーブルを作ってる
#
#  ジョブの共有ストレージ．
#  内部的にはHashにしている
#
#  KVSとして使う事を想定
#
#     require 'noda'
#     server =Noda::JobServer.new
#     table = server.hash_table #<= 自分でインスタンス化しない．Jobサーバーから使う
#     table.put "key, "value"
#  タスクから使う場合。
#     do_task(hash_table)
#       v = hash_table.get "key"
#       hash_table.put "key", "value2" # =>更新
#     end
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
  # キー対応した値を取り出す
  def get(key)
    @hash[key][:data]
  end
  # キーを名前に値を保存する．
  def put(key, obj)
    self.synchronize{
      @hash[key] = {:data=>obj,:saved=>false}
    }
  end
  # キーがテーブルに存在するか
  def has_key?(key) @hash.has_key? key end
  # alias to has_key
  alias :exists? :has_key?
  # キーを全部取得
  def keys() @hash.keys end
  # テーブルの値の数
  def size() @hash.size end
  # Enumerable 用。
  #
  # drb 経由で呼び出す時は、参照渡しになるので注意
  def each 
    @hash.each_pair{|k,v| yield( k,v[:data] )  }
    nil
  end
  
  # テーブルの値はDump済みかどうか
  #
  # 永続ストレージに書き出すときに
  # このフラグを使って処理をする
  def saved?(key)
    @hash[key][:saved]
  end
  # テーブルの値の保存状態を更新する．
  #
  # 永続ストレージに書き出すときに
  # このフラグを使って処理をする
  def update_saved_at(key,status=true)
    self.synchronize{
      @hash[key][:saved]=status
    }
  end
  # テーブルの未保存の値をすべて取り出す．」
  #
  # 永続ストレージに書き出すときに
  # このメソッドを使って処理が出来る
  def each_unsaved_pair
    @hash.each_pair{|k,v| next if v[:saved]; yield( k, v[:data] )  }
    nil
  end
  # 未保存の値があるか
  #
  # 永続ストレージに書き出すときに
  # このフラグを使って処理をする
  def has_unsaved_key?
    return true if @hash.find{|k,v| v[:saved]==false}
    return false
  end
end

end

