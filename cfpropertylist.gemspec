Gem::Specification.new do |s|
  s.name = "CFPropertyList"
  s.version = "4.0.0"
  s.author = "Christian Kruse"
  s.email = "cjk@defunct.ch"
  s.homepage = "https://github.com/ckruse/CFPropertyList"
  s.license = 'MIT'
  s.summary = "Read, write and manipulate both binary and XML property lists as defined by apple"
  s.description = "This is a module to read, write and manipulate both binary and XML property lists as defined by apple."
  s.files = Dir.glob("lib/**/*") + ['LICENSE', 'README.md', 'THANKS', 'README.rdoc']
  s.extra_rdoc_files = ["README.rdoc"]

  s.required_ruby_version = ">= 3.2"

  # no longer bundled with Ruby 3
  s.add_dependency("rexml")

  # no longer bundled with Ruby >= 3.4
  s.add_dependency("nkf")
  s.add_dependency("base64")
end
