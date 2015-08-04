# pcb cookbook

The "Pipeline Cookbook" - `pcb` - is, inceptionally speaking, a ChefDK code generator cookbook for creating build cookbooks for use with Chef Delivery pipeline phases.

This cookbook also serves as a complete example "cookbook generator cookbook," complete with tests, and its own integration with Chef Delivery.

This cookbook is shared via GitHub. It is not shared on Supermarket because the primary consumer of it is  delivery-cli's `init` sub-command, which clones the repository to a cached location.

# Requirements

- ChefDK 0.6.2+
- Delivery CLI 2015-07-15T15:38:10Z (954e60c)

Due to the nature of Chef Delivery (continuous delivery), we recommend that users have the latest version of ChefDK and delivery-cli installed on their local systems.

In order to use Test Kitchen to run verification on the local system, the following are also required:

- Vagrant
- Virtualbox or VMware Fusion

It is left as an exercise to the reader to make sure those are configured for using Test Kitchen. The generated `.kitchen.yml` can be modified to use other provisioners, too.

# Usage Demo

Set up a project for Chef Delivery. For example purposes, we'll create a new cookbook, and make an initial commit.

```
chef generate cookbook maelstrom
cd maelstrom
git add .
git commit -m 'A swirling vortex of rain'
delivery setup --ent ENTERPRISE --org ORGNAME --server delivery.example.com --user USERNAME --for master
echo '.delivery/cli.toml' >> .gitignore
delivery token
delivery init
```

If the installed delivery-cli does not create the build cookbook, you can do that manually:

```
git clone https://github.com/chef-cookbooks/pcb.git ~/.delivery/cache/generator-cookbooks/pcb
chef generate cookbook .delivery/build-cookbook -g ~/.delivery/cache/generator-cookbooks/pcb
```

If the project is a cookbook like our example, this will generate the `.delivery/build-cookbook` as a wrapper for [delivery-truck](https://github.com/opscode-cookbooks/delivery-truck). If the project is something else, such as a Java or Rails application, the `.delivery/build-cookbook` will be an empty skeleton. Either way, it can then be modified as required to run the project through Chef Delivery's phases.

Once this is complete, edit your `.delivery/config.json` to point at the generated build cookbook:
```
  "build_cookbook": {
    "name": "build-cookbook",
    "path": ".delivery/build-cookbook"
  },
```

# License and Author

Based on the [ChefDK code_generator](https://github.com/chef/chef-dk/tree/master/lib/chef-dk/skeletons/code_generator)

Further modifications:

- Author: Joshua Timberman <joshua@chef.io>
- Author: Jon Anderson <janderson@chef.io>
- Author: Stephen Lauck <laucks@chef.io>

Copyright:: Copyright (c) 2015, Chef Software, Inc. <legal@chef.io>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
