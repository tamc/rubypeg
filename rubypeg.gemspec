Gem::Specification.new do |s|
  s.name = "rubypeg"
  s.version = '0.0.2'
  s.author = "Thomas Counsell, Green on Black Ltd"
  s.email = "ruby-peg@greenonblack.com"
  # s.homepage = "http://functionalform.blogspot.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "A zero dependency ruby parsing expression grammar (PEG) creator"
  s.files = ["LICENSE", "README", "{spec,lib,bin,doc,examples}/**/*"].map{|p| Dir[p]}.flatten
  s.executables = ["text-peg2ruby-peg"]
  s.require_path = "lib"
  s.has_rdoc = true
end