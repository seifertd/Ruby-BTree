# frozen_string_literal: true
source "https://rubygems.org"
#repo_name "seifertd/Ruby-BTree"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# gem "rails"

# Added at 2017-11-09 08:39:45 -0800 by doug:
gem "rake", "~> 13", :group => [:development, :test]

# Added at 2017-11-09 08:40:02 -0800 by doug:
gem "bones", "~> 3.9", :group => [:development, :test]

gem "minitest", :group => [:development, :test]
# Added at 2017-11-09 08:40:12 -0800 by doug:
# shoulda-context supplies the context/should DSL the tests use.  The shoulda
# meta-gem would also pull in shoulda-matchers, whose only purpose is Rails
# model assertions this project has no use for, and which drags in the whole
# activesupport tree behind it.
gem "shoulda-context", "~> 1.0", :group => [:development, :test]
