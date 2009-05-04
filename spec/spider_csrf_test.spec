#!/usr/bin/env ruby
require 'wwmd'
include WWMD
require 'spec'

describe Page do
  before(:each) do
    @page = Page.new({:base_url => "http://localhost"})
    @spider = @page.spider
    @spider.csrf_token = "CsRf"
  end

  it "should remove csrf tokens from visited and queued" do
    url = "http://localhost/foo.php?CsRf=something&bar=baz"
    links = ["http://localhost/q1.php?CsRf=omg&first=FIRST"]
    @spider.add(url,links)
    @spider.visited.first.should == "http://localhost/foo.php?CsRf=&bar=baz"
    @spider.queued.first.should == "http://localhost/q1.php?CsRf=&first=FIRST"
  end

  it "should work normally" do
    url = "http://localhost/foo.php?hithere=something&bar=baz"
    links = ["http://localhost/q1.php?hithere=omg&first=FIRST"]
    @spider.add(url,links)
    @spider.visited.first.should == "http://localhost/foo.php?hithere=something&bar=baz"
    @spider.queued.first.should == "http://localhost/q1.php?hithere=omg&first=FIRST"
  end
end
