module WWMD
  class WWMDConfig

    def self.load_config(file)
      begin
        config = YAML.load_file(file)
      rescue => e
        putw "config file not found #{file}"
        putw e.inspect
        exit
      end
      return config
    end

    def self.parse_opts(args)
      inopts = Hash.new
      opts = OptionParser.new do |opts|
        # set defaults
        opts.on("-p", "--password PASSWORD", "Password")     { |v| inopts[:password] = v }
        opts.on("-u", "--username USERNAME", "Username")     { |v| inopts[:username] = v }
        opts.on("--header_file HEADER_FILE","Header file")   { |v| inopts[:header_file] = v }
        opts.on("--base_url BASE_URL","Base url")            { |v| inopts[:base_url] = v }
        opts.on("--use_proxy PROXY_URL", "Use proxy at url") do |v|
          ENV['HTTP_PROXY'] = "http://" + v.to_s
          inopts[:use_proxy] = true
          inopts[:proxy_url] = v
        end
        opts.on("--no_proxy","do not use proxy") do |v|
          inopts[:use_proxy] = false
          inopts[:proxy_url] = nil
        end
        opts.on("--use_auth","login before getting url")     { |v| inopts[:use_auth] = true }
        opts.on("--no_auth","no login before getting url")   { |v| inopts[:use_auth] = false }
        opts.on("--debug","debugging really doesn't work")   { |v| inopts[:debug] = true }
        opts.on_tail("-h", "--help", "Show this message") do
          putx opts
          exit
        end
      end
      opts.parse!(args)
      return inopts
    end
  end
end
