#!/usr/bin/env ruby
require 'rubygems'
require 'ruby-debug'
require 'wwmd'
include WWMD

$stop = lambda { Debugger.breakpoint; Debugger.catchpoint }

module WWMD
	class Page
		# here we add directly to Page.login instead of creating an outside
		# helper class.  Normally we create a mixin script for this.
		def login
			self.get(self.opts[:base_url])             ;# GET the main page redirects to /login
			form = self.get_form                       ;# get the login form
			if form.nil? then                          ;# did we actually get a form?
				puts "WARN: No login form on base page"
				return (self.logged_in = false)
			end
			form.set("name",self.opts[:username])      ;# set login form variables from config
			form.set("password",self.opts[:password])
			self.url = self.action                     ;# set the url to submit to to the form action
			self.submit(form)                          ;# submit the form

			# perform some check to make sure we aren't still on the login page
			# (this naively checks to make sure we don't have any password fields on the current page
			self.logged_in = (self.search("//input[@type='password']").size == 0)
		end
	end
end

# parse options and load configuration file
inopts = WWMDConfig.parse_opts(ARGV)
conf = ARGV[0] || "./config_example.yaml"
opts = WWMDConfig.load_config(conf)
inopts.each_pair { |k,v| opts[k] = v }
$opts = opts

# create our Page object and name it page
page = Page.new(opts)
page.scrape.warn = false  ;# don't complain about not overwriting scrape

# move our spider object up here
spider = page.spider

# output current configuration
puts "current configuration:\n"
page.opts.each_pair { |k,v|
	if k == :password then
		puts "#{k} :: ********"
	else
		puts "#{k} :: #{v}"
	end
}
puts "\n"

# use the Helper method to login to the application
if page.opts[:use_auth] then
	page.login
	if page.logged_in? then
		puts "logged in as #{opts[:username]}"
	else
		puts "WARN: could not log in" if !page.logged_in?
	end
else
	page.get opts[:base_url]
end

# report our current location and let's drop to irb with
# our whole context complete
puts "current location: #{page.current}"
puts "enter \"irb\" to go to the console"

$stop.call
