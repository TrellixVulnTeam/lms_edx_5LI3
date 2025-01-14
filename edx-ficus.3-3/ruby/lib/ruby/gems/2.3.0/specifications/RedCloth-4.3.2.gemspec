# -*- encoding: utf-8 -*-
# stub: RedCloth 4.3.2 ruby lib lib/case_sensitive_require ext
# stub: ext/redcloth_scan/extconf.rb

Gem::Specification.new do |s|
  s.name = "RedCloth".freeze
  s.version = "4.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze, "lib/case_sensitive_require".freeze, "ext".freeze]
  s.authors = ["Jason Garber".freeze, "Joshua Siler".freeze, "Ola Bini".freeze]
  s.date = "2016-05-24"
  s.description = "Textile parser for Ruby.".freeze
  s.email = "redcloth-upwards@rubyforge.org".freeze
  s.executables = ["redcloth".freeze]
  s.extensions = ["ext/redcloth_scan/extconf.rb".freeze]
  s.extra_rdoc_files = ["README.rdoc".freeze, "COPYING".freeze, "CHANGELOG".freeze]
  s.files = ["CHANGELOG".freeze, "COPYING".freeze, "README.rdoc".freeze, "bin/redcloth".freeze, "ext/redcloth_scan/extconf.rb".freeze]
  s.homepage = "http://redcloth.org".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze, "--line-numbers".freeze, "--inline-source".freeze, "--title".freeze, "RedCloth".freeze, "--main".freeze, "README.rdoc".freeze]
  s.rubyforge_project = "redcloth".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "RedCloth-4.3.2".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["> 1.3.4"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0.3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.4"])
      s.add_development_dependency(%q<diff-lcs>.freeze, ["~> 1.1.2"])
    else
      s.add_dependency(%q<bundler>.freeze, ["> 1.3.4"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0.3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.4"])
      s.add_dependency(%q<diff-lcs>.freeze, ["~> 1.1.2"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["> 1.3.4"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.4"])
    s.add_dependency(%q<diff-lcs>.freeze, ["~> 1.1.2"])
  end
end
