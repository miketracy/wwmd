# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'wwmd'

task :default => 'spec:run'

PROJ.name = 'wwmd'
PROJ.authors = 'Michael L. Tracy'
PROJ.email = 'mtracy@matasano.com'
PROJ.url = 'http://github.com/miketracy/wwmd/tree/master'
PROJ.version = WWMD::VERSION
#PROJ.rubyforge.name = 'wwmd'

PROJ.spec.opts << '--color'

depend_on 'ruby-debug'
depend_on 'curb'
depend_on 'nokogiri'

# EOF
