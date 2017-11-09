
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'btree'
  authors  'Douglas A. Seifert'
  email    'doug@dseifert.net'
  url      'https://github.com/seifertd/Ruby-BTree'
  readme_file 'README.md'
}

