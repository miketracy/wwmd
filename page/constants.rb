module WWMD
  XSSFISH = "<;'\"}()[]>{"

  DEFAULTS = {
    :use_auth => true,
    :enable_cookies => true,
    :cookiejar => "./__cookiejar",
    :follow_location => true,
    :max_redirects => 20,
    :use_proxy => false,
    :debug => false,
    :scrape_warn => false,
    :parse => true,
    :timeout => 20,
  }

  ESCAPE = {
    :url     => /[^a-zA-Z0-9%]/,
    :nalnum  => /[^a-zA-Z0-9]/,
    :xss     => /[^a-zA-Z0-9=?&()']/,
    :ltgt    => /[<>]/,
    :all     => /.*/,
    :b64     => /[=+]/,
    :none    => :none,
    :default => :default,
  }

  UA = {
    :mozilla => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16",
    :moz3 => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1",
    :ie6 => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)",
    :ie7 => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)",
    :ie8 => "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)",
    :opera => "Opera/9.20 (Windows NT 6.0; U; en)",
    :safari => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; en) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"
  }

  DEFAULT_HEADERS = {
    "User-Agent" => UA[:moz3],
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language" => "en-US,en;q=0.8,en-au;q=0.6,en-us;q=0.4,en;q=0.2",
    "Accept-Encoding" => "gzip,deflate",
    "Accept-Charset" => "SO-8859-1,utf-8;q=0.7,*;q=0.7",
    "Keep-Alive" => "300",
    "Connection" => "keep-alive",
  }

  HEADERS = {
    :default => nil,
    :utf7 => {
      "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-7",
      "Content-Transfer-Encoding" => "7bit",
    },
    :ajax => {
      "X-Requested-With" => "XMLHttpRequest",
      "X-Prototype-Version" => "1.5.0",
    },
  }
end
