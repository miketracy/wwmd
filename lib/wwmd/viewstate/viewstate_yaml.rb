class String
# right now I have no idea why "\x0d\x0a" is getting munged in yaml transforms
# something weird helped find by timur@.  double up "\r" before "\n" works
# this might be mac specific and break on other platforms.  I don't care.
# patch not for general use do not try this at home.
  def to_yaml( opts = {} )
    YAML::quick_emit( is_complex_yaml? ? object_id : nil, opts ) do |out|
      if is_binary_data?
        out.scalar( "tag:yaml.org,2002:binary", [self].pack("m"), :literal )
      elsif ( self =~ /\r\n/ )
#        out.scalar( "tag:yaml.org,2002:binary", [self].pack("m"), :literal )
        out.scalar( taguri, self.gsub(/\r\n/,"\r\r\n"), :quote2 )
      elsif to_yaml_properties.empty?
        out.scalar( taguri, self, self =~ /^:/ ? :quote2 : to_yaml_style )
      else
        out.map( taguri, to_yaml_style ) do |map|
          map.add( 'str', "#{self}" )
          to_yaml_properties.each do |m|
            map.add( m, instance_variable_get( m ) )
          end
        end
      end
    end
  end
end
