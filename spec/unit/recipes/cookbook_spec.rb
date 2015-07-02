require 'spec_helper'

describe 'pcb::cookbook' do
  let(:skip_git_init) { true }
  let(:have_git) { false }
  let(:cookbook_root) { '/var/tmp' }
  let(:cookbook_name) { 'pcb' }
  let(:cookbook_path_in_git_repo?) { false }
  let(:recipe_name) { 'cookbook' }
  let(:license) { 'apache2' }

  before(:each) do
    ChefDK::Generator.add_attr_to_context(:skip_git_init, cookbook_path_in_git_repo?)
    ChefDK::Generator.add_attr_to_context(:have_git, have_git)
    ChefDK::Generator.add_attr_to_context(:cookbook_root, cookbook_root)
    ChefDK::Generator.add_attr_to_context(:cookbook_name, cookbook_name)
    ChefDK::Generator.add_attr_to_context(:recipe_name, recipe_name)
    ChefDK::Generator.add_attr_to_context(:license, license)
  end

  context 'Default for one of our target platforms' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ).converge(described_recipe)
    end

    it 'converges without error' do
      expect { chef_run }.to_not raise_error
    end

    # we know that if the generate command does not specify the
    # license option, `all_rights` is used, so let's test for a
    # non-default option like our favorite license, `apache2`. we
    # don't need to test it twice.
    it 'renders the LICENSE file from the correct template source' do
      expect(chef_run).to create_template_if_missing('/var/tmp/pcb/LICENSE').with(source: 'LICENSE.apache2.erb')
    end
  end
end
