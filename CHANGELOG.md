# CHANGELOG

### Version 1.0.2

2019-01-21

[Compare changes](https://github.com/tf/semmy/compare/v1.0.1...v1.0.2)

- Ensure test install of gem during `release:prepare` does not hang
  waiting for interactive input on uninstall.

### Version 1.0.1

2018-12-10

[Compare changes](https://github.com/tf/semmy/compare/v1.0.0...v1.0.1)

- Require date stdlib to prevent error during prepare.

### Version 1.0.0

2017-07-13

[Compare changes](https://github.com/tf/semmy/compare/0-x-stable...v1.0.0)

##### Breaking Changes

- A typo in the name of the `changelog_unreleased_section_heading` and
  `changelog_unreleased_section_blank_slate` options was fixed.
- The default value of `changelog_unreleased_section_heading` changed
  to "Unreleased Changes". You need to update the header in your
  changelog or manually set the previous value via the configuration option.

##### New Features

- Add `bump:patch` task which begins a patch level release.
- Add `bump:mahor` task which updates the major version.

##### Bug Fixes

- Fix indentation of generated unreleased changes section.

See
[0-x-stable branch](https://github.com/tf/semmy/blob/0-x-stable/CHANGELOG.md)
for previous changes.
