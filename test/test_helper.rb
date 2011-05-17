require 'stringio'
require 'test/unit'
require 'rubygems'
require 'drb/drb'
require File.dirname(__FILE__) + '/../lib/noda'

require 'noda'
require 'noda/job_server'
require 'noda/job_worker'
require 'noda/rqueue'
require 'noda/table'
require 'noda/task'
include Noda
