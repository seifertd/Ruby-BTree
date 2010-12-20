
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
  url      'http://www.dseifert.net/btree'
  readme_file 'README.md'
}

