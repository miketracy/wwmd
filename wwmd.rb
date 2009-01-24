#!/usr/bin/env ruby
#:include:sig.do

module WWMD
  PARSER = :nokogiri  # :nokogiri || :hpricot
end
# third-party
require 'rubygems'
require 'ruby-debug'
require 'curb'
if WWMD::PARSER == :nokogiri
  require 'nokogiri'
  HDOC = Nokogiri::HTML
  require 'lib/nokogiri_html2text'
else
  require 'hpricot'
  HDOC = Hpricot
  require 'lib/hpricot_html2text'
end
require 'yaml'
require 'fileutils'
require 'base64'
require 'optparse'
require 'digest'
require 'uri'
require 'htmlentities'
require 'nkf'

# here beginneth the libraries
require 'page'
require 'page/constants'
require 'page/headers'
require 'page/inputs'
require 'page/irb_helpers'
require 'page/auth'
require 'page/utils'
require 'page/config'
require 'page/urlparse'
require 'page/scrape'
require 'page/spider'

require 'lib/encoding'
require 'lib/guid' #fixed for mac
require 'lib/form'
require 'lib/form_array'
#require 'lib/html2text'
require 'lib/mixins'
require 'lib/mixins_extends'

$stdout.sync = true

module WWMD; end
