module WWMD
  attr_accessor :console
  attr_accessor :debug
  @console = false
  @debug = false
  def self.putd(*args); puts *args if WWMD::debug; end
  def self.putx(*args); puts *args if WWMD::console; end
  def self.putw(*args); puts *args if WWMD::console; end
end
