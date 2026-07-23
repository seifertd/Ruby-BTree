require 'rake/testtask'
require 'rake/clean'
require 'rubygems/package_task'

SPEC = Gem::Specification.load('btree.gemspec')

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
  sh 'gem', 'install', "pkg/#{SPEC.full_name}.gem"
end

namespace :release do
  desc 'Check the working tree and metadata are fit to release'
  task :check do
    version = SPEC.version.to_s

    unless `git status --porcelain`.strip.empty?
      abort 'ERROR: working tree is dirty. Commit or stash before releasing.'
    end

    branch = `git rev-parse --abbrev-ref HEAD`.strip
    unless `git rev-parse #{branch}`.strip == `git rev-parse origin/master`.strip
      warn "WARNING: #{branch} does not match origin/master."
    end

    if `git tag -l v#{version}`.strip == "v#{version}"
      abort "ERROR: tag v#{version} already exists. Bump version.txt first."
    end

    # RubyGems refuses a re-push of a version that has ever been released, even
    # a yanked one, so catch the collision here rather than after the tag.
    require 'open-uri'
    begin
      released = URI.open("https://rubygems.org/api/v1/versions/#{SPEC.name}.json").read
      if released.include?(%Q("number":"#{version}"))
        abort "ERROR: #{SPEC.name} #{version} is already on rubygems.org."
      end
    rescue OpenURI::HTTPError => e
      warn "WARNING: could not check rubygems.org (#{e.message}); continuing."
    end

    unless File.read('History.txt').start_with?("== #{version} ")
      abort "ERROR: History.txt has no entry for #{version}."
    end

    puts "OK: ready to release #{SPEC.name} #{version}."
  end

  desc 'Tag the release and push the tag to origin'
  task :tag => :check do
    version = SPEC.version.to_s
    sh 'git', 'tag', '-a', "v#{version}", '-m', "#{SPEC.name} #{version}"
    sh 'git', 'push', 'origin', "v#{version}"
  end

  # repackage, not build: the packaged gem is a file task, so an existing
  # pkg/*.gem newer than its sources satisfies :build without rebuilding. That
  # is fine locally and completely wrong when the next step is an irreversible
  # push, so a release always rebuilds from scratch.
  desc 'Push the built gem to rubygems.org'
  task :push => :repackage do
    sh 'gem', 'push', "pkg/#{SPEC.full_name}.gem"
  end
end

desc 'Run the full release: check, test, rebuild, tag, push to rubygems.org'
task :release => ['release:check', :test] do
  Rake::Task['release:tag'].invoke
  Rake::Task['release:push'].invoke
  puts "Released #{SPEC.name} #{SPEC.version}."
end
