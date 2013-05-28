# third-party
require 'rubygems'
unless self.respond_to?(:java)
#  require 'ruby-debug'
else
#  I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true
#  require 'curb_ffi'
#  include CurbFfi
end
require 'curb'
require 'yaml'
require 'fileutils'
require 'base64'
require 'optparse'
require 'digest'
require 'uri'
require 'htmlentities'
require 'nkf'
require 'rexml/document'
load    'version.rb'

module WWMD

  # :stopdoc:
  PARSER = :nokogiri
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each do |rb|
      next if rb =~ /html2text/
      require rb
    end
  end

end  # module WWMD

WWMD.require_all_libs_relative_to(__FILE__)

require 'nokogiri'
WWMD::HDOC = Nokogiri::HTML
require 'wwmd/page/html2text'

# EOF
