#!/usr/bin/env ruby
#:include:sig.do

module WWMD
  VERSION = "0.2.8"
  PARSER = :nokogiri  # :nokogiri || :hpricot
end
# third-party
require 'rubygems'
require 'ruby-debug'
require 'curb'
if WWMD::PARSER == :nokogiri
  require 'nokogiri'
  HDOC = Nokogiri::HTML
#  HDOC = Nokogiri::XML
  require 'nokogiri_html2text'
else
  require 'hpricot'
  HDOC = Hpricot
  require 'hpricot_html2text'
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

require 'encoding'
require 'guid' #fixed for mac
require 'form'
require 'form_array'
#require 'html2text'
require 'mixins'
require 'mixins_extends'

$stdout.sync = true

module WWMD; end
