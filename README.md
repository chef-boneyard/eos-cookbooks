eos-cookbooks
=============

This repository contains cookbooks for configuration Arista switches
running EOS.

The cookbooks here have only been tested against a vEOS image running
under VMware Fusion

Install
-------
See [INSTALL.md](INSTALL.md) for more instructions on how to install and configure
chef on EOS.

Roles
-----
There is a `eos-base` role which sets up paths and loads recipes to
configure ohai plugins and interface scripts.

Cookbooks
----
There are two main cookbooks - `eos` and `eos_demo`.

* eos
This contains ohai plugins for reporting eos-specific information such
as that returned by `show version` under `node['eos']` and some
information on configured interfaces under `node['sysdb']`.

There is also a  wrapper script for the Sysdb python API that allows us
to modify interface attributes (enabled/disabled and description).

* eos_demo
This has a sample recipe which can enable/disable the `Ethernet1`
interface depending on the value of the attribute
`node['eos_demo']['enabled']`.  This is set, by default, to `false` in
the `eos-base` role.

LICENCE
-------
Author: James Casey <james@opscode.com>
Copyright: Copyright (c) 2012 Opscode, Inc.
License: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
