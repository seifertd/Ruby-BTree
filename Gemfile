# frozen_string_literal: true
source "https://rubygems.org"

# Runtime dependencies come from btree.gemspec, which declares none.
gemspec

# shoulda-context supplies the context/should DSL the tests use. The shoulda
# meta-gem would also pull in shoulda-matchers, whose only purpose is Rails
# model assertions this project has no use for, and which drags in the whole
# activesupport tree behind it.
group :development, :test do
  gem "rake", "~> 13"
  gem "minitest", "~> 6.0"
  gem "shoulda-context", "~> 2.0"
end
