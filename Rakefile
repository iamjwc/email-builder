require 'rubygems'
require 'spec/rake/spectask'

$: << File.dirname(__FILE__)

Spec::Rake::SpecTask.new do |t|
  t.spec_opts << "-c"
  t.spec_files = FileList['spec/**/*_spec.rb']
end

