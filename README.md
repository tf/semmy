# Semmy

[![Gem Version](https://badge.fury.io/rb/semmy.svg)](http://badge.fury.io/rb/semmy)
[![Dependency Status](https://gemnasium.com/badges/github.com/tf/semmy.svg)](https://gemnasium.com/github.com/tf/semmy)
[![Build Status](https://travis-ci.org/tf/semmy.svg?branch=master)](https://travis-ci.org/tf/semmy)
[![Coverage Status](https://coveralls.io/repos/github/tf/semmy/badge.svg?branch=master)](https://coveralls.io/github/tf/semmy?branch=master)
[![Code Climate](https://codeclimate.com/github/tf/semmy/badges/gpa.svg)](https://codeclimate.com/github/tf/semmy)

An opinionated set of rake tasks to maintain gems following semantic
versioning principles.

## Assumptions

### Git Branches and Tags

Development happens directly on `master` or by merging pull
requests. When a release is made, a stable branch called `x-y-stable`
is created. Semmy relies on Bundler's `release` task to create version
tags.

Patch level versions are released via backports to the stable
branches.

### Version Suffix

The version in the gem's version file is increased in a separate
commit right after release. The version always has an `dev` suffix
(i.e. `1.1.0.dev`), which is only removed in the last commit
preparing the release. That way it is easy to see in a project's
`Gemfile.lock` whether an unreleased version is used.

Patch level versions are expected to be released immediately after
backporting bug fixes. So there are never commits with a version
suffix on stable branches.

### Doc Tags

Pull requests introducing new features, are expected to markup new
code elements with a `@since edge` doc tag. When a release is
prepared, `edge` is replaced with the current version string. That way
pull request authors do not have to guess, which version will merge
their commits.

### Changelog

Unreleased changes are listed in a section at the top. When preparing
a release this section is closed by placing a version heading above it
and inserting a compare link. Changelog entries for patch level
versions are only committed on the stable branches since they only
backport bug fixes from master.

## Installation

Add development dependency to your gemspec:

    # your.gemspec
    s.add_development_dependency 'semmy', '~> 1.0'

Install gems:

    $ bundle

Add the tasks to your Rakefile:

    # Rakefile
    require 'semmy'

    Semmy::Tasks.install

You can pass config options:

    # Rakefile
    require 'semmy'

    Semmy::Tasks.install do |config|
      # see Semmy::Configuration for options
    end

## Usage

Semmy defines a new task to prepare a release:

    $ rake release:prepare

This task:

* Ensures the gem can be installed.
* Removes the `dev` version suffix from the version file.
* Rewrites doc tags.
* Closes the section of the new version in the changelog.
* Commits the changes.

It is expected that a `release` task exists. Normally this tasks is
provided by Bundler.

    $ rake release

Semmy registers additional actions which shall be
executed right after the release:

* Creates a stable branch.
* Bumps the version to the next minor version with `alpha` version
  suffix.
* Inserts an "Unreleased Changes" section in the changelog.

The resulting commit graph looks like:

    * (master) Bump version to 1.3.0.dev
    * (v1.2.0, 1-2-stable) Prepare 1.2.0 release
    * Some new feature

By default, the new stable branch and the bump commit are not pushed
automatically. This can be activated by setting the
`push_branches_after_release` config option to `true`.

This will be the new default once Semmy 2.0 is released. You can opt
into the future default behavior globally without changing config
options on the project level by setting the
`SEMMY_PUSH_BRANCHES_AFTER_RELEASE` environment variable to `on`.

Branches will be pushed to the remote passed as an argument to the
`release` task:

    $ rake release[upstream]

By default, branches are pushed to `origin`.

### Releasing a Patch Level Version

Assume an important bug fix has been added to `master`:

    * (master) Important bug fix
    * First new feature
    * Bump version to 1.3.0.dev
    * (v1.0.0, 1-2-stable) Prepare 1.2.0 release

check out the stable branch and cherry pick commits:

    $ git checkout 1-2-stable
    $ git cherry-pick master

Then run:

    $ rake bump:patch

This task:

* Bumps the version to `1.2.1` in the version file.
* Inserts an "Unreleased Changes" section in the changelog.

Add items to the new changelog section, then run:

    $ rake release:prepare

This task detects that we are currently on a stable branch and
performs the following subset of the normal prepare tasks:

* Closes the section of the new version in the changelog.
* Commits the changes

You can now run `rake release`, leaving you with the following commit
graph:

    * (master) Important bug fix
    * First new feature
    * Bump version to 1.3.0.dev
    | * (v1.2.1, 1-2-stable) Prepare 1.2.1 release
    | * Important bug fix
    |/
    * (v1.2.0) Prepare 1.2.0 release

### Releasing a Major Version

If breaking changes have been merged to master, run:

    $ rake bump:major

Assuming the version was `1.2.0.dev` before, This bumps the major
version in the version file to `2.0.0.dev` and updates the changelog
to reference `1-x-stable` for comparison.

The branch `1-x-stable` has to be created and managed manually. It
should always point to the same commit as the lastest minor version
stable branch of the major version.

The rest of the release can be performed like a normal minor version
release.

## Development

After checking out the repo, run `bin/setup` to install
dependencies. You can also run `bin/console` for an interactive prompt
that will allow you to experiment. Run `bin/rspec` to execute the test
suite.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/tf/semmy.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
