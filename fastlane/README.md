fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### version

```sh
[bundle exec] fastlane version
```

Prints the version and build number

----


## iOS

### ios certs

```sh
[bundle exec] fastlane ios certs
```

Creates a signing certificate and provisioning profile

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Runs all unit and UI tests

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generates localized screenshots

### ios frames

```sh
[bundle exec] fastlane ios frames
```

Creates new screenshots from existing ones that have device frames

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Uploads localized screenshots to App Store

### ios build

```sh
[bundle exec] fastlane ios build
```

Builds the app and produces symbol and ipa files.

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Deploys app to TestFlight

### ios comet

```sh
[bundle exec] fastlane ios comet
```

Call Comet

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
