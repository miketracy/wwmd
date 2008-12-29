#!/usr/bin/env ruby
#:include:sig.do
#
# This is where we do all the undocumented auth stuff.  NTLM is here and hooked in.
#
# WWMDNTLM is an incredibly naive NTLM implementation (used to get 
# around NTLM for one project ahwile back


module WWMD
  class Page

#:stopdoc:

#:section: Authentication helpers

    # check if this request requires NTLM
    def ntlm?
      return false if self.code != "401"
      count = 0
      self.header_data.each do |i|
        if i[0] =~ /www-authenticate/i then
          count += 1 if (i[1] == "Negotiate" || i[1] == "NTLM")
        end
      end
      return true if count > 0
      return false
    end

    # does this request have an authenticate header?
    def auth?
      return false if self.code != "401"
      count = 0
      self.header_data.each do |i|
        if i[0] =~ /www-authenticate/i then
          count += 1
        end
      end
      return true if count > 0
      return false
    end

    # not sure why this is here
    def ntlm_perform(exp=nil)
      self.perform
      return false if self.code != exp
      return true
    end

    # perform a get usig NTLM
    def ntlm_get(url=nil?,debug=false)
      self.clear_header('Authorization')
      nobj = WWMDNTLM.new(self.opts)
      self.url = url if not url.nil?
      self.perform
      return "This request does not appear to require NTLM" if not self.ntlm?
      self.headers['Authorization'] = nobj.type_1_msg
      self.perform
      type2 = self.header_data.get_value('WWW-Authenticate')
      nonce = nobj.get_nonce(type2)
      type3 = nobj.type_3_msg(nonce)
      self.headers['Authorization'] = type3
      self.perform
      self.clear_header('Authorization')
      return self.code
    end

    alias nget ntlm_get

#:startdoc:

  end

  class WWMDNTLM#:nodoc:
    attr_accessor :hostname
    attr_accessor :domain
    attr_accessor :username
    attr_accessor :password
    attr_accessor :opts
    attr_accessor :negotiate_flags
    attr_accessor :debug

    def initialize(opts,debug=false)
      @opts = opts
      @hostname = self.opts[:hostname]
      @domain   = self.opts[:domain]
      @username = self.opts[:username]
      @password = self.opts[:password]
      @hostname = "LOCALHOST" if self.hostname.nil?
      @negotiate_flags = 0x00002201.to_l32
      @debug = debug
    end

    def type_1_msg
# do not add domain for now here as it doesn't seem to be needed
# it does need to be set for type3 messages
      host_len = self.hostname.size
      host_off = 0x20
#      if self.domain.nil?
      if true
        dom_off = 0
        dom_len = 0
      else
        dom_off = (host_off + hostname.size)
        dom_len = self.domain.size
      end
      msg = ""
      msg << "NTLMSSP\x00"        # signature[8]
      msg << 0x01.to_l32          # type[4]
      msg << self.negotiate_flags # NegotiateFlags[4]
      msg << dom_len.to_l16       # domain string length[2]
      msg << dom_len.to_l16       # domain string length[2]
      msg << dom_off.to_l32       # domain string offset[4]
      msg << host_len.to_l16      # host string length[2]
      msg << host_len.to_l16      # host string length[2]
      msg << host_off.to_l32      # host string offset[4]
#      msg << self.domain if not self.domain.nil? # domain[var]
      msg << self.hostname        # host name[var]
      return "NTLM " + msg.b64e
    end

    def get_nonce(t2msg)
      # Signature[8]
      # MessageType[4]
      # TargetNameFields[8]
      # NegotiateFlags[4]
      # ServerChallenge[8]
      # Reserved[8] ! 0x00
      # TargetInfoFields[8]
      # Version[8]
      # Payload[var]
      msg = t2msg.split[1].b64d
      return msg[24..31]
    end

    def type_3_msg(nonce)
      hlen = 0x40
      poff = hlen
      domain = self.domain.to_utf16
      username = self.username.to_utf16
      hostname = self.hostname.to_utf16
      lmresp = NTLM.lm_response(self.opts[:password],nonce,:lmhash)
      ntresp = NTLM.lm_response(self.opts[:password],nonce,:nthash)
      msg = ""
      msg << "NTLMSSP\x00"            # Signature[8]
      msg << 0x03.to_l32              # MessageType[4]
                                      # LmChallengeResonseFields[8]
      msg << lmresp.size.to_l16           # LmChallengeResponseLen[2]
      msg << lmresp.size.to_l16           # LmChallengeResponseMaxLen[2]
      msg << poff.to_l32                  # LmChallengeResponseBufferOffset[4]
      poff += lmresp.size
#      msg << 0x40.to_l32                  # LmChallengeResponseBufferOffset[4]
                                      # NtChallengeResponseFields[8]
      msg << ntresp.size.to_l16           # NtChallengeResponseLen[2]
      msg << ntresp.size.to_l16           # NtChallengeResponseMaxLen[2]
#      msg << 0x58.to_l32                  # NtChallengeResponseBufferOffset[4]
      msg << poff.to_l32                  # NtChallengeResponseBufferOffset[4]
      poff += ntresp.size
                                      # DomainNameFields[8]
      msg << domain.size.to_l16           # DomainNameLen[2]
      msg << domain.size.to_l16           # DomainNameMaxLen[2]
      msg << poff.to_l32                  # DomainNameBufferOffset[4]
      poff += domain.size
                                      # UserNameFields[8]
      msg << username.size.to_l16         # UserNameLen[2]
      msg << username.size.to_l16         # UserNameMaxLen[2]
      msg << poff.to_l32                  # UserNameBufferOffset[4]
      poff += username.size
                                      # WorkstationFields[8]
      msg << hostname.size.to_l16         # WorkstationLen[2]
      msg << hostname.size.to_l16         # WorkstationMaxLen[2]
      msg << poff.to_l32                  # WorkstationBufferOffset[4]
      poff += hostname.size
                                      # EncryptedRandomSessionKeyFields[8]
      msg << 0x00.to_l16                  # EncryptedRandomSessionKeyLen[2]
      msg << 0x00.to_l16                  # EncryptedRandomSessionKeyMaxLen[2]
      msg << 0x00.to_l32                  # EncryptedRandomSessionKeyBufferOffset[4]
      msg << self.negotiate_flags     # NegotiateFlags[4]
                                      # Version[8] (optional do not add)
                                      # Payload[var]
      msg << lmresp                       # LmChallenge[var]
      msg << ntresp                       # NtChallenge[var]
      msg << domain                       # DomainName[var]
      msg << username                     # UserName[var]
      msg << hostname                     # Workstation[var]
      return "NTLM " + msg.b64e
    end
  end
end
