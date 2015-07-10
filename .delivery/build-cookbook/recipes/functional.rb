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

# Our target cookbook name setup in the provision recipe is maelstrom.
# We need to dance over to the provision directory because that's
# where we cached the pcb generator cookbook
build_cookbook_path = File.expand_path(File.join(node['delivery']['workspace']['repo'],
                                                 '..', '..', 'provision', 'repo', 'maelstrom',
                                                 '.delivery', 'build-cookbook'))

# Enable audit mode, because it'll be disabled by default. This will
# fail if the chef client is below 12.1.0, but we're fine here because
# our delivery builders have ChefDK.
Chef::Config[:audit_mode] = :enabled

control_group 'Verify Build Cookbook' do
  control 'It wraps delivery-truck' do
    it 'has delivery-truck in the berksfile' do
      expect(file("#{build_cookbook_path}/Berksfile").content).to match(/cookbook 'delivery-truck'/)
    end

    it 'has delivery-sugar in the berksfile' do
      expect(file("#{build_cookbook_path}/Berksfile").content).to match(/cookbook 'delivery-sugar'/)
    end

    it 'depends on delivery-truck' do
      expect(file("#{build_cookbook_path}/metadata.rb").content).to match(/depends 'delivery-truck'/)
    end

    # .each an array
    %w(default deploy functional lint provision publish quality security smoke syntax unit).each do |phase|
      it "includes the delivery-truck recipe in #{phase}" do
        expect(file("#{build_cookbook_path}/recipes/#{phase}.rb").content).to match(
          /include_recipe 'delivery-truck::#{phase}'/
        )
      end
    end
  end
end
