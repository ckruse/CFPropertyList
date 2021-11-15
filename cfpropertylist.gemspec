Gem::Specification.new do |s|
  s.name = "CFPropertyList"
  s.version = "3.0.5"
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
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0.0')
    s.add_runtime_dependency("rexml") # no longer bundled with Ruby 3
  end
  s.add_development_dependency("libxml-ruby")
  s.add_development_dependency("minitest")
  s.add_development_dependency("nokogiri")
  s.add_development_dependency("rake",">=0.7.0")
end
