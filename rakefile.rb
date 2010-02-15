require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  files = ['README', 'LICENCE','lib/ruby_peg.rb','lib/text_peg2ruby_peg.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = 'README'
  rdoc.title = 'Ruby PEG'
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
end