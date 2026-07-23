# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'btree'
  # version.txt stays the single source of truth: Btree.version reads it back
  # at runtime, so it has to ship in the gem regardless.
  s.version     = File.read(File.expand_path('version.txt', __dir__)).strip
  s.authors     = ['Douglas A. Seifert']
  s.email       = 'doug@dseifert.net'
  s.homepage    = 'https://github.com/seifertd/Ruby-BTree'
  s.license     = 'MIT'

  s.summary     = 'Pure ruby implementation of a btree'
  s.description = <<~DESC
    Pure ruby implementation of a btree as described in Introduction to
    Algorithms by Cormen, Leiserson, Rivest and Stein, Chapter 18.
  DESC

  # Array#bsearch_index, used by Node#key_index, is the oldest thing here that
  # is not universally available. CI only exercises 3.2 and up, because that is
  # the floor imposed by the development gems, not by the library.
  s.required_ruby_version = '>= 2.3.0'

  # Rejecting dotfiles drops .github/, .gitignore and the .ruby-* files, which
  # is the same set the old Bones exclude list named by hand. Building outside
  # a git checkout is not supported, which matches how this gem is released.
  s.files = `git ls-files -z`.split("\x0").reject {|f| f.start_with?('.') }

  s.require_paths      = ['lib']
  s.extra_rdoc_files   = ['History.txt', 'README.md']
  s.rdoc_options       = ['--main', 'README.md']

  s.metadata = {
    'homepage_uri'    => s.homepage,
    'source_code_uri' => s.homepage,
    'changelog_uri'   => "#{s.homepage}/blob/master/History.txt",
    'bug_tracker_uri' => "#{s.homepage}/issues",

    # Requires that whoever pushes this gem has MFA enabled on their
    # rubygems.org account, so a leaked API key is not enough on its own.
    # This needs MFA turned on for the account first, or the push is rejected.
    'rubygems_mfa_required' => 'true'
  }
end
