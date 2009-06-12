require 'wwmd/viewstate/viewstate_utils'
module WWMD
  class ViewState
    include ViewStateUtils
  end
end
require 'rubygems'
require 'nokogiri'
require 'rexml/document'
require 'htmlentities'
Dir.glob(::File.join(::File.dirname(__FILE__),"mixins*.rb")).each { |rb| require rb }
require 'wwmd/viewstate/viewstate'
require 'wwmd/viewstate/viewstate_types'
require 'wwmd/viewstate/viewstate_yaml'
require 'wwmd/viewstate/viewstate_deserializer_methods'
require 'wwmd/viewstate/viewstate_from_xml'
require 'wwmd/viewstate/vs_stubs'
