	<;'"}()[]>{  XSSFish says, "Swim wif me"

## Blah blah blah

WWMD was originally intended to provide a console helper tool for 
conducting web application security assessments (which is something I 
find myself doing alot of).  I've spent alot of time and had alot of 
success writing application specific fuzzers + scrapers to test with.  
WWMD provides a base of useful code to help you work with web sites both 
in IRB and by writing scripts that can be as generic or as application 
specific as you choose.

There's alot of helpful stuff crammed in here and its usage has evolved 
alot.  It's not intended to replace, remove or be better than any of the 
tools you currently use.  In fact, WWMD works best *with* the tools you 
currently use to get stuff done.  You get convenience methods for 
getting, scraping, spidering, decoding, decrypting and munging user 
inputs, pages and web applications.

It doesn't try to be smart.  That's up to you.

What's here is the basic framework for getting started.  There's a raft 
of cookbook scripts and examples that are coming soon so make sure you 
check the wiki regularly.

### WWMD relies on these ruby libraries:

* rubygems
* ruby-debug
* curb
* hpricot
* htmlentities
