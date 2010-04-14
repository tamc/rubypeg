require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  files = ['README', 'LICENCE','lib/rubypeg.rb','lib/text_peg2rubypeg.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = 'README'
  rdoc.title = 'Ruby PEG'
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
end