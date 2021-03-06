# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: wwmd 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "wwmd".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Tracy".freeze]
  s.date = "2019-03-03"
  s.description = "".freeze
  s.email = "mike.tracy@gmail.com".freeze
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "History.txt",
    "README.rdoc",
    "Rakefile",
    "examples/config_example.yaml",
    "examples/wwmd_example.rb",
    "lib/version.rb",
    "lib/wwmd.rb",
    "lib/wwmd/class_extensions.rb",
    "lib/wwmd/class_extensions/extensions_base.rb",
    "lib/wwmd/class_extensions/extensions_encoding.rb",
    "lib/wwmd/class_extensions/extensions_external.rb",
    "lib/wwmd/class_extensions/extensions_nilclass.rb",
    "lib/wwmd/class_extensions/extensions_rbkb.rb",
    "lib/wwmd/class_extensions/mixins_string_encoding.rb",
    "lib/wwmd/guid.rb",
    "lib/wwmd/page.rb",
    "lib/wwmd/page/auth.rb",
    "lib/wwmd/page/constants.rb",
    "lib/wwmd/page/form.rb",
    "lib/wwmd/page/form_array.rb",
    "lib/wwmd/page/headers.rb",
    "lib/wwmd/page/helpers.rb",
    "lib/wwmd/page/html2text.rb",
    "lib/wwmd/page/inputs.rb",
    "lib/wwmd/page/irb_helpers.rb",
    "lib/wwmd/page/page.rb",
    "lib/wwmd/page/parsing_convenience.rb",
    "lib/wwmd/page/reporting_helpers.rb",
    "lib/wwmd/page/scrape.rb",
    "lib/wwmd/page/spider.rb",
    "lib/wwmd/urlparse.rb",
    "lib/wwmd/viewstate.rb",
    "lib/wwmd/viewstate/viewstate.rb",
    "lib/wwmd/viewstate/viewstate_deserializer_methods.rb",
    "lib/wwmd/viewstate/viewstate_from_xml.rb",
    "lib/wwmd/viewstate/viewstate_types.rb",
    "lib/wwmd/viewstate/viewstate_utils.rb",
    "lib/wwmd/viewstate/viewstate_yaml.rb",
    "lib/wwmd/viewstate/vs_stubs.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_array.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_binary_serialized.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_hashtable.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_hybrid_dict.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_indexed_string.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_indexed_string_ref.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_int_enum.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_list.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_pair.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_read_types.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_read_value.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_sparse_array.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_string.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_string_array.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_string_formatted.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_stub_helpers.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_triplet.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_type.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_unit.rb",
    "lib/wwmd/viewstate/vs_stubs/vs_value.rb",
    "lib/wwmd/wwmd_config.rb",
    "lib/wwmd/wwmd_puts.rb",
    "lib/wwmd/wwmd_utils.rb",
    "spec/README",
    "spec/form_array.spec",
    "spec/spider_csrf_test.spec",
    "spec/urlparse_test.spec",
    "tasks/ann.rake",
    "tasks/bones.rake",
    "tasks/gem.rake",
    "tasks/git.rake",
    "tasks/notes.rake",
    "tasks/post_load.rake",
    "tasks/rdoc.rake",
    "tasks/rubyforge.rake",
    "tasks/setup.rb",
    "tasks/spec.rake",
    "tasks/test.rake",
    "tasks/zentest.rake",
    "wwmd.gemspec"
  ]
  s.homepage = "http://github.com/miketracy/wwmd/tree/master".freeze
  s.rubygems_version = "2.6.12".freeze
  s.summary = "framework and helpers for conducting web application security assessments".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<htmlentities>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<xml-simple>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<curb>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
    else
      s.add_dependency(%q<htmlentities>.freeze, [">= 0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_dependency(%q<xml-simple>.freeze, [">= 0"])
      s.add_dependency(%q<curb>.freeze, [">= 0"])
      s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<htmlentities>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<xml-simple>.freeze, [">= 0"])
    s.add_dependency(%q<curb>.freeze, [">= 0"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
  end
end

