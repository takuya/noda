require 'rubygems'
require 'drb/drb'
require 'logger'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'noda/rqueue'
require 'noda/job_server'
require 'noda/job_monitor'
require 'noda/job_worker'
require 'noda/table'
require 'noda/task'
require 'noda/table'
require 'noda/table_auto_saver'

module Noda
  #VERSION = '0.0.1'
end

