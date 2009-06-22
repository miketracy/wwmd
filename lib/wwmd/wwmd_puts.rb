module WWMD
  attr_accessor :console
  attr_accessor :debug
  @console = false
  @debug = false
  def putd(*args); puts *args if WWMD::debug; end
  def putx(*args); puts *args if WWMD::console; end
  def putw(*args); puts *args if WWMD::console; end
end
