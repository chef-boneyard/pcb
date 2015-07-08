#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright 2015 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cache = node['delivery']['workspace']['cache']
cookbook_name = 'maelstrom'
path = "#{node['delivery']['workspace']['repo']}/#{cookbook_name}"
github_repo = node['delivery']['config']['delivery-truck']['publish']['github']

execute "chef generate cookbook #{cookbook_name}" do
  cwd node['delivery']['workspace']['repo']
end

# we're not doing `delivery init`, so we need to make the directory
directory File.join(path, '.delivery')

execute 'git add and commit' do
  cwd path
  command <<-EOF.gsub(/^\s*/, '')
    git add .
    git commit -m 'a swirling vortex of terror'
  EOF
end

git "#{cache}/.delivery/cache/generator-cookbooks/pcb" do
  repository github_repo
  checkout_branch 'master'
  revision 'master'
  action :sync
end

execute 'generate build-cookbook' do
  cwd path
  command "chef generate cookbook .delivery/build-cookbook -g #{cache}/.delivery/cache/generator-cookbooks/pcb"
end
