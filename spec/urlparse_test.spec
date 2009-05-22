#!/usr/bin/env ruby
require 'wwmd/urlparse'
include WWMD
require 'spec'

describe URLParse do
  before(:each) do
    @base = "https://www.base.com"
    @up = URLParse.new()
  end

  it "should parse the basic case" do
    @up.parse("https://www.location.com/","/path/path/path/script.scr").to_s.should \
      == "https://www.location.com/path/path/path/script.scr"
    @up.proto.should == "https"
    @up.location.should == "www.location.com"
    @up.path.should == "/path/path/path/"
    @up.script.should == "script.scr"
    @up.parse("https://www.location.com/","/path/path/path/script").to_s.should \
      == "https://www.location.com/path/path/path/script"
    @up.proto.should == "https"
    @up.location.should == "www.location.com"
    @up.path.should == "/path/path/path/script"
#    @up.script.should == nil
    @up.script.should == ""
  end

  it "should parse when complete urls are passed" do
    @up.parse(@base,"https://www.location.com/hithere/dirname/test.php").to_s.should \
      == "https://www.location.com/hithere/dirname/test.php"
    @up.proto.should == "https"
    @up.location.should == "www.location.com"
    @up.path.should == "/hithere/dirname/"
    @up.script.should == "test.php"
  end

  it "should parse GET params correctly" do
    @up.parse(@base,"http://www.location.com/test.php?foo=bar&baz=eep").to_s.should \
      == "http://www.location.com/test.php?foo=bar&baz=eep"
  end

  it "should return the path if the path is fully qualified" do
    @up.parse(@base,"http://www.location.com/").to_s.should == "http://www.location.com/"
    @up.parse(@base,"http://www.location.com").to_s.should  == "http://www.location.com/"
  end

  it "should parse a location + relative link" do
    @up.parse("https://www.location.com","relative/script.scr").to_s.should \
      == "https://www.location.com/relative/script.scr"
  end

  it "should parse base urls with scripts (page.cur) + relative link" do
    @up.parse("https://www.location.com/path/to/a_script.php", "more/script.scr").to_s.should == "https://www.location.com/path/to/more/script.scr"
  end

  it "should parse base urls without scripts + relative link" do
    @up.parse("https://www.location.com/path/to/end", "but/more/script.scr").to_s.should \
      == "https://www.location.com/path/to/end/but/more/script.scr"
  end

  it "should handle trailing slashes correctly" do
    @up.parse(@base + "/","/test.php").to_s.should == "#{@base}/test.php"
    @up.parse(@base + "/","/test.php").to_s.should_not == "#{@base}//test.php"
  end

  it "should parse dotdot correctly" do
    @up.parse(@base + "/one/two/thee/four","../../foo.php").to_s.should \
      == "#{@base}/one/two/foo.php"
    @up.parse(("https://www.location.com/relative///path//deep/one"),"more/..//stuff/../foo.php").to_s.should \
      == "https://www.location.com/relative/path/deep/one/foo.php"
    @up.parse("https://www.location.com/rel/path/foo.php","../../../../../../bar.php").to_s.should \
      == "https://www.location.com/bar.php"
  end

  it "should parse dot correctly" do
    @up.parse("https://www.location.com","base/./../foo/././bar/script.scr").to_s.should \
      == "https://www.location.com/foo/bar/script.scr"
  end

  it "should remove get params when posting to a form action with get params" do
    @up.parse("https://www.location.com/mail/h/1nyas6k8hplt9/?s=t","?s=t&at=xn3j38mvpzxqd138zgwsooxvojvbvd").to_s.should \
      == "https://www.location.com/mail/h/1nyas6k8hplt9/?s=t&at=xn3j38mvpzxqd138zgwsooxvojvbvd"
  end

  it "should not remove directory traversal params" do
    @up.parse("http://www.example.com/?file=../../../../../../etc/passwd&param1=foobar.log&param2=false").to_s.should \
      == "http://www.example.com/?file=../../../../../../etc/passwd&param1=foobar.log&param2=false"
  end

  it "should not remove directory traversal params 2" do
    @up.parse("http://www.example.com:8888/foobar/barBaz.do?logFile=../../../../../../../../../../../../etc/passwd&foo=foobar.log&bazeep=false").to_s.should \
      == "http://www.example.com:8888/foobar/barBaz.do?logFile=../../../../../../../../../../../../etc/passwd&foo=foobar.log&bazeep=false"
  end

  it "should not remove directory traversal params 2" do
    @up.parse("http://www.example.com:8888", "/foobar/barBaz.do?logFile=../../../../../../../../../../../../etc/passwd&foo=foobar.log&bazeep=false").to_s.should \
      == "http://www.example.com:8888/foobar/barBaz.do?logFile=../../../../../../../../../../../../etc/passwd&foo=foobar.log&bazeep=false"
  end

end

