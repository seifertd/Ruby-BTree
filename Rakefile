
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
  # Setting exclude replaces the Bones defaults, which is why '^pkg/' has to be
  # named here: without it, build products from previous releases under pkg/
  # get swept into the manifest and shipped inside the next gem.
  exclude ['.bnsignore', '.gitignore', '.github', '.ruby-gemset', '.ruby-version', '^pkg/', 'vendor', '.git']
}

