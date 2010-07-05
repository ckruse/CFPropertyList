require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  s.name = "CFPropertyList"
  s.version = "2.0.7"
  s.author = "Christian Kruse"
  s.email = "cjk@wwwtech.de"
  s.homepage = "http://github.com/ckruse/CFPropertyList"
  s.platform = Gem::Platform::RUBY
  s.summary = "Read, write and manipulate both binary and XML property lists as defined by apple"
  s.description = "This is a module to read, write and manipulate both binary and XML property lists as defined by apple."
  s.rubyforge_project = 'cfpropertylist'
  s.files = FileList["lib/*"].to_a
  s.require_path = "lib"
  #s.autorequire = "name"
  #s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.add_dependency("libxml-ruby", ">= 1.1.0")
  s.add_dependency("rake",">=0.7.0")
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end

# eof