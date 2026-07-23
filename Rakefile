require 'rake/testtask'
require 'rake/clean'
require 'rubygems/package_task'

SPEC = Gem::Specification.load('btree.gemspec')
VERSION = SPEC.version.to_s
GEM_FILE = "pkg/#{SPEC.full_name}.gem"

CLOBBER.include('pkg', 'doc')

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList['test/test_*.rb']
end

task :default => :test

Gem::PackageTask.new(SPEC) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

desc 'Build the gem into pkg/'
task :build => :package

desc 'Install the built gem locally'
task :install => :build do
  sh 'gem', 'install', GEM_FILE
end

# Shells out with Bundler's environment stripped. Anything that inspects the
# gem as an end user would -- installing it, requiring it -- has to run outside
# this project's bundle, or it picks up the working tree instead of the package.
def unbundled(*cmd)
  require 'bundler'
  Bundler.with_unbundled_env { sh(*cmd) }
rescue LoadError
  sh(*cmd)
end

def rubygems_versions
  require 'open-uri'
  require 'json'
  JSON.parse(URI.open("https://rubygems.org/api/v1/versions/#{SPEC.name}.json").read)
rescue OpenURI::HTTPError, SocketError, JSON::ParserError => e
  warn "WARNING: could not reach rubygems.org (#{e.class}: #{e.message})."
  nil
end

namespace :release do
  desc 'Check the working tree, metadata and credentials are fit to release'
  task :check do
    problems = []

    problems << 'working tree is dirty; commit or stash first' unless
      `git status --porcelain`.strip.empty?

    # The tag has to point at a commit that exists somewhere other than this
    # laptop, otherwise a published gem can be built from work nobody else has.
    if `git branch -r --contains HEAD 2>/dev/null`.strip.empty?
      problems << 'HEAD is not on any remote branch; push it before releasing'
    end

    problems << "tag v#{VERSION} already exists; bump version.txt" if
      `git tag -l v#{VERSION}`.strip == "v#{VERSION}"

    problems << "History.txt has no entry for #{VERSION}" unless
      File.read('History.txt').start_with?("== #{VERSION} ")

    # A version number is the one genuinely unrecoverable resource in a
    # release: RubyGems refuses to re-push it even after a yank.
    if (published = rubygems_versions)
      problems << "#{SPEC.name} #{VERSION} is already on rubygems.org" if
        published.any? {|v| v['number'] == VERSION }
    end

    # Surfaced now rather than as a 403 after the tag has been pushed.
    unless ENV['GEM_HOST_API_KEY'] || File.exist?(File.expand_path('~/.gem/credentials'))
      problems << 'no rubygems credentials found; run `gem signin` (the key needs the push_rubygem scope)'
    end

    branch = `git rev-parse --abbrev-ref HEAD`.strip
    warn "WARNING: releasing from #{branch}, not master." unless branch == 'master'

    unless problems.empty?
      abort "ERROR: not ready to release #{SPEC.name} #{VERSION}:\n" +
            problems.map {|p| "  - #{p}" }.join("\n")
    end

    puts "OK: #{SPEC.name} #{VERSION} passes pre-release checks."
  end

  desc 'Build the gem and prove the built artifact actually works'
  task :verify => :repackage do
    require 'tmpdir'

    puts "Packaged #{GEM_FILE}:"
    Gem::Package.new(GEM_FILE).spec.files.each {|f| puts "  #{f}" }

    # Installing into a throwaway GEM_HOME is the only check that covers what
    # was actually packaged rather than what is sitting in the working tree --
    # a file missing from the manifest looks fine locally and breaks on install.
    Dir.mktmpdir do |dir|
      unbundled 'gem', 'install', '--no-document', '--install-dir', dir, GEM_FILE

      script = <<~RUBY
        gem 'btree'
        require 'btree'
        raise "version mismatch: \#{Btree.version} != #{VERSION}" unless Btree.version == '#{VERSION}'
        t = Btree.create(3)
        (1..50).each {|i| t[i] = i.to_s }
        got = t[10..14]
        raise "bad range query: \#{got.inspect}" unless got == %w[10 11 12 13 14]
        raise "bad lookup" unless t[37] == '37'
        puts "smoke test passed on the installed gem"
      RUBY

      Dir.chdir(dir) do
        unbundled({'GEM_HOME' => dir, 'RUBYOPT' => nil}, RbConfig.ruby, '-e', script)
      end
    end
  end

  desc 'Tag the release and push the tag to origin (reversible)'
  task :tag do
    sh 'git', 'tag', '-a', "v#{VERSION}", '-m', "#{SPEC.name} #{VERSION}"
    sh 'git', 'push', 'origin', "v#{VERSION}"
    puts "Tagged v#{VERSION}. To undo: git tag -d v#{VERSION} && git push origin :v#{VERSION}"
  end

  # repackage, not build: the packaged gem is a file task, so an existing
  # pkg/*.gem newer than its sources satisfies :build without rebuilding. Fine
  # locally, wrong when the next step is irreversible.
  desc 'Push the gem to rubygems.org (IRREVERSIBLE)'
  task :push => :repackage do
    puts
    puts "About to push #{GEM_FILE} to rubygems.org."
    puts "This cannot be undone: #{SPEC.name} #{VERSION} can never be re-pushed,"
    puts 'even if it is yanked afterwards.'

    unless ENV['FORCE'] == '1'
      abort 'ERROR: refusing to push from a non-interactive shell without FORCE=1.' unless $stdin.tty?
      print "Type the version (#{VERSION}) to confirm: "
      abort 'Aborted.' unless $stdin.gets.to_s.strip == VERSION
    end

    sh 'gem', 'push', GEM_FILE
  end

  desc 'Confirm the version is live on rubygems.org'
  task :confirm do
    published = rubygems_versions
    if published&.any? {|v| v['number'] == VERSION }
      puts "Confirmed: #{SPEC.name} #{VERSION} is live on rubygems.org."
    else
      warn "WARNING: #{SPEC.name} #{VERSION} is not visible on rubygems.org yet (indexing can lag)."
    end
  end
end

desc 'Full release: check, test, verify the built gem, tag, then push'
task :release do
  # Ordered so that everything reversible happens first. The tag is cheap to
  # delete; the push is permanent, so it goes last and only after the packaged
  # gem has been installed and exercised.
  %w[release:check test release:verify release:tag release:push release:confirm].each do |t|
    puts "\n==> #{t}"
    Rake::Task[t].invoke
  end
  puts "\nReleased #{SPEC.name} #{VERSION}."
end
