Gem::Specification.new do |s|
  s.name = "CFPropertyList"
  s.version = "3.0.3"
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
  s.add_development_dependency("rake",">=0.7.0")
end