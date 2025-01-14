# -*- encoding: utf-8 -*-
# stub: rdoc 4.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rdoc".freeze
  s.version = "4.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eric Hodel".freeze, "Dave Thomas".freeze, "Phil Hagelberg".freeze, "Tony Strauss".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDeDCCAmCgAwIBAgIBATANBgkqhkiG9w0BAQUFADBBMRAwDgYDVQQDDAdkcmJy\nYWluMRgwFgYKCZImiZPyLGQBGRYIc2VnbWVudDcxEzARBgoJkiaJk/IsZAEZFgNu\nZXQwHhcNMTMwMjI4MDUyMjA4WhcNMTQwMjI4MDUyMjA4WjBBMRAwDgYDVQQDDAdk\ncmJyYWluMRgwFgYKCZImiZPyLGQBGRYIc2VnbWVudDcxEzARBgoJkiaJk/IsZAEZ\nFgNuZXQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCbbgLrGLGIDE76\nLV/cvxdEzCuYuS3oG9PrSZnuDweySUfdp/so0cDq+j8bqy6OzZSw07gdjwFMSd6J\nU5ddZCVywn5nnAQ+Ui7jMW54CYt5/H6f2US6U0hQOjJR6cpfiymgxGdfyTiVcvTm\nGj/okWrQl0NjYOYBpDi+9PPmaH2RmLJu0dB/NylsDnW5j6yN1BEI8MfJRR+HRKZY\nmUtgzBwF1V4KIZQ8EuL6I/nHVu07i6IkrpAgxpXUfdJQJi0oZAqXurAV3yTxkFwd\ng62YrrW26mDe+pZBzR6bpLE+PmXCzz7UxUq3AE0gPHbiMXie3EFE0oxnsU3lIduh\nsCANiQ8BAgMBAAGjezB5MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdDgQW\nBBS5k4Z75VSpdM0AclG2UvzFA/VW5DAfBgNVHREEGDAWgRRkcmJyYWluQHNlZ21l\nbnQ3Lm5ldDAfBgNVHRIEGDAWgRRkcmJyYWluQHNlZ21lbnQ3Lm5ldDANBgkqhkiG\n9w0BAQUFAAOCAQEAOflo4Md5aJF//EetzXIGZ2EI5PzKWX/mMpp7cxFyDcVPtTv0\njs/6zWrWSbd60W9Kn4ch3nYiATFKhisgeYotDDz2/pb/x1ivJn4vEvs9kYKVvbF8\nV7MV/O5HDW8Q0pA1SljI6GzcOgejtUMxZCyyyDdbUpyAMdt9UpqTZkZ5z1sicgQk\n5o2XJ+OhceOIUVqVh1r6DNY5tLVaGJabtBmJAYFVznDcHiSFybGKBa5n25Egql1t\nKDyY1VIazVgoC8XvR4h/95/iScPiuglzA+DBG1hip1xScAtw05BrXyUNrc9CEMYU\nwgF94UVoHRp6ywo8I7NP3HcwFQDFNEZPNGXsng==\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2013-03-27"
  s.description = "RDoc produces HTML and command-line documentation for Ruby projects.  RDoc\nincludes the +rdoc+ and +ri+ tools for generating and displaying documentation\nfrom the command-line.".freeze
  s.email = ["drbrain@segment7.net".freeze, "".freeze, "technomancy@gmail.com".freeze, "tony.strauss@designingpatterns.com".freeze]
  s.executables = ["rdoc".freeze, "ri".freeze]
  s.extra_rdoc_files = ["CVE-2013-0256.rdoc".freeze, "DEVELOPERS.rdoc".freeze, "History.rdoc".freeze, "LEGAL.rdoc".freeze, "LICENSE.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "RI.rdoc".freeze, "TODO.rdoc".freeze, "bin/rdoc".freeze, "Rakefile".freeze]
  s.files = ["CVE-2013-0256.rdoc".freeze, "DEVELOPERS.rdoc".freeze, "History.rdoc".freeze, "LEGAL.rdoc".freeze, "LICENSE.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "RI.rdoc".freeze, "Rakefile".freeze, "TODO.rdoc".freeze, "bin/rdoc".freeze, "bin/ri".freeze]
  s.homepage = "http://docs.seattlerb.org/rdoc".freeze
  s.licenses = ["Ruby".freeze]
  s.post_install_message = "Depending on your version of ruby, you may need to install ruby rdoc/ri data:\n\n<= 1.8.6 : unsupported\n = 1.8.7 : gem install rdoc-data; rdoc-data --install\n = 1.9.1 : gem install rdoc-data; rdoc-data --install\n>= 1.9.2 : nothing to do! Yay!\n".freeze
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubyforge_project = "rdoc".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "RDoc produces HTML and command-line documentation for Ruby projects".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<kpeg>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 4.6"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.10"])
      s.add_development_dependency(%q<racc>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<ZenTest>.freeze, ["~> 4"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.5"])
    else
      s.add_dependency(%q<json>.freeze, ["~> 1.4"])
      s.add_dependency(%q<kpeg>.freeze, ["~> 0.9"])
      s.add_dependency(%q<minitest>.freeze, ["~> 4.6"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 3.10"])
      s.add_dependency(%q<racc>.freeze, ["~> 1.4"])
      s.add_dependency(%q<ZenTest>.freeze, ["~> 4"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.5"])
    end
  else
    s.add_dependency(%q<json>.freeze, ["~> 1.4"])
    s.add_dependency(%q<kpeg>.freeze, ["~> 0.9"])
    s.add_dependency(%q<minitest>.freeze, ["~> 4.6"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.10"])
    s.add_dependency(%q<racc>.freeze, ["~> 1.4"])
    s.add_dependency(%q<ZenTest>.freeze, ["~> 4"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.5"])
  end
end
