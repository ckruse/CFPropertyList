Gem::Specification.new do |s|
  s.name = "CFPropertyList"
  s.version = "3.0.8"
  s.author = "Christian Kruse"
  s.email = "cjk@defunct.ch"
  s.homepage = "https://github.com/ckruse/CFPropertyList"
  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY
  s.summary = "Read, write and manipulate both binary and XML property lists as defined by apple"
  s.description = "This is a module to read, write and manipulate both binary and XML property lists as defined by apple."
  s.files = Dir.glob("lib/**/*") + ['LICENSE', 'README.md', 'THANKS', 'README.rdoc']
  s.require_path = "lib"
  #s.autorequire = "name"
  #s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.extra_rdoc_files = ["README.rdoc"]

  s.required_ruby_version = Gem::Requirement.new(">= 3.2")

  # no longer bundled with Ruby 3
  s.add_runtime_dependency("rexml")

  # no longer bundled with Ruby >= 3.4
  s.add_runtime_dependency("nkf")
  s.add_runtime_dependency("base64")

  s.add_development_dependency("libxml-ruby")
  s.add_development_dependency("minitest")
  s.add_development_dependency("nokogiri")
  s.add_development_dependency("rake",">=0.7.0")
end
