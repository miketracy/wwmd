#!/usr/bin/env ruby
require 'wwmd'
include WWMD
require 'spec'

describe FormArray do
  before(:each) do
    @form = FormArray.new
  end

  it "sets a value and reads a value" do
    @form["foo"] = "bar"
    @form["foo"].should == "bar"
  end

  it "reads from a string" do
    @form = "foo=bar&baz=eep&argle=bargle".to_form
    @form["foo"].should == "bar"
    @form["baz"].should == "eep"
    @form["argle"].should == "bargle"
  end

  it "to_get" do
    str = "foo=bar&baz=eep&argle=bargle"
    get = "?" + str
    @form = str.to_form
    @form.to_get.should == get
  end

  it "remove_nulls!" do
    @form["var1"] = "not null"
    @form["var2"] = ""
    @form["var3"] = nil
    @form.remove_nulls!
    @form.size.should == 1
    @form["var1"].should == "not null"
  end

  it "clones correctly" do
    @form = "foo=bar&baz=eep&argle=bargle".to_form
    lform = @form.clone
    lform["foo"] = "test"
    @form["foo"].should == "bar"
    lform["foo"].should == "test"
  end

  it "escapes characters correctly"
  it "unescapes characters correctly"
end
