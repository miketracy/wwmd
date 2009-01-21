#!/usr/bin/env ruby
#:include:sig.do

module WWMD
  PARSER = :hpricot  # :nokogiri || :hpricot
end
# third-party
require 'rubygems'
require 'ruby-debug'
require 'curb'
if WWMD::PARSER == :nokogiri
  require 'nokogiri'
  include Nokogiri
else
  require 'hpricot'
  include Hpricot
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
if WWMD::PARSER == :nokogiri
  require 'page/nokogiri_scrape'
else
  require 'page/hpricot_scrape'
end
require 'page/spider'

require 'lib/encoding'
require 'lib/guid' #fixed for mac
if WWMD::PARSER == :nokogiri
  require 'lib/nokogiri_form'
  require 'lib/nokogiri_form_array'
  require 'lib/nokogiri_html2text'
else
  require 'lib/hpricot_form'
  require 'lib/hpricot_form_array'
  require 'lib/hpricot_html2text'
end
require 'lib/mixins'
require 'lib/mixins_extends'

$stdout.sync = true

module WWMD; end
