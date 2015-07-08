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

build_cookbook_path = "#{node['delivery']['workspace']['repo']}/#{cookbook_name}"

control_group 'Verify Build Cookbook' do
  control 'It wraps delivery-truck' do
    it 'has delivery-truck in the berksfile' do
      expect(file("#{build_cookbook_path}/Berksfile").content).to match(/cookbook 'delivery-truck'/)
    end

    it 'has delivery-sugar in the berksfile' do

    end

    it 'depends on delivery-truck' do
      expect(file("#{build_cookbook_path}/metadat.rb").content).to match(/depends 'delivery-truck'/)
    end

    # .each an array
    it 'includes the delivery-truck recipes in each generated recipe' do

    end
  end
end
