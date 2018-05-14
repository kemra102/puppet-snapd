# snapd

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with snapd](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module manages the `snapd` package and service. `snapd` is a tool that enables the installation of `snap` packages on a Linux system.

See the [official website](http://snapcraft.io/) for more detailed information.

## Setup

### What snapd affects

This module currently manages the following items:

* The `snapd` package.
* The `snapd` service.

## Usage

To use this module simply include it:

```puppet
class { 'snapd': }
```

or

```puppet
include ::snapd
```

### Unsupported Operating Systems

If your OS is not listed in [Limitations](#Limitations) it may still work regardless.

Debian Sid for example should work without any changes.

## Reference

### snapd

This is the main class. Currently it has no configurable items.

## Limitations

Supported Operating Systems:

* Arch Linux
* Ubuntu 16.04 & 16.10

Supported Puppet Versions:

* Puppet Enterprise >= 2015.2
* Puppet Open Source >= 4.0.0

## Provider
We provide a basic package provider which allows installs and removes, we will need to add latest,query and update support in the future.

## Development

To contribute to the development of this module please raise a pull request.

Particular help is currently highly desired particularly on the following items:

* Package provider query,latest and update functionality
* Support for more Operating Systems.
* More testing.
