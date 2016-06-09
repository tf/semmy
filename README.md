# Semmy

[![Gem Version](https://badge.fury.io/rb/semmy.svg)](http://badge.fury.io/rb/semmy)
[![Build Status](https://travis-ci.org/tf/semmy.svg?branch=master)](https://travis-ci.org/tf/semmy)

An opinionated set of rake tasks to maintain gems following semantic
versioning principles.

## Installation

Add development dependency to your gemspec:

    # your.gemspec
    s.add_development_dependency "semmy", "~> 1.0"

Install gems:

    $ bundle

Add the tasks to your Rakefile:

    # Rakefile
    require 'semmy'

    Semmy::Tasks.install

## Usage

Semmy defines a new task to prepare a release:

    $ rake release:prepare

This task:

* Removes the `dev` version suffix from the version file
* Rewrites doc tags
* Closes the section of the new version in the changelog.
* Commits the changes

It is expected that a `release` task exists. Normally this tasks is
provided by Bundler.

    $ rake release

Semmy registers additional actions which shall be
executed right after the release:

* Creates a stable branch
* Bumps the version to the next minor version with `alpha` version
  suffix.
* Inserts an "Changes on master" section in the changelog.

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
commit right after release. The version always has an `alpha` suffix
(i.e. `1.1.0.alpha`), which is only removed in the last commit
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

## Example Life Cycle

### Releasing a Minor Version

     1:  * (master) Other important bug fix
     2:  * Minor bug fix
     3:  * First new feature
     4:  * Important bug fix
     5:  * Begin work on 1.1
     6:  | * (1-0-stable, v1.0.2) Prepare 1.0.2 release
     7:  | * Backport of other bug fix
     8:  | * (v1.0.1) Prepare 1.0.1 release
     9:  | * Backport of important bug fix
    10:  |/
    11:  * (v1.0.0) Prepare 1.0.0 release

### Releasing a Patch Level Version


