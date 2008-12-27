#!/usr/bin/env ruby
#:include:sig.do

#IRB.conf[:IRB_NAME] = "wwmd"

# third-party
require 'rubygems'
require 'ruby-debug'
require 'curb'
require 'hpricot'
Hpricot.buffer_size = 262144
include Hpricot
require 'yaml'
require 'fileutils'
require 'base64'
require 'optparse'
require 'openssl'
require 'uri'
require 'htmlentities'
require 'nkf'

# here beginneth the libraries
require 'page'
require 'page_constants'
require 'page_headers'
require 'page_inputs'
require 'page_irb'
require 'page_auth'
require 'page_utils'
require 'page_config'
require 'page_urlparse'
require 'scrape'
require 'spider'

require 'lib/encoding'
require 'lib/guid' #fixed for mac
require 'lib/hpricot_form'
require 'lib/hpricot_form_array'
require 'lib/html2text'
require 'lib/mixins'
require 'lib/mixins_extends'

$stdout.sync = true

module WWMD; end
