require 'spec_helper'

describe 'pcb::cookbook' do
  let(:skip_git_init) { true }
  let(:have_git) { false }
  let(:cookbook_root) { '/var/tmp/pcb' }
  let(:cookbook_name) { 'pcb' }
  let(:license) { 'apache2' }
  let(:cookbook_path_in_git_repo?) { false }
  let(:recipe_name) { 'cookbook' }

  before(:each) do
    ChefDK::Generator.add_attr_to_context(:skip_git_init, cookbook_path_in_git_repo?)
    ChefDK::Generator.add_attr_to_context(:have_git, have_git)
    ChefDK::Generator.add_attr_to_context(:cookbook_root, cookbook_root)
    ChefDK::Generator.add_attr_to_context(:cookbook_name, cookbook_name)
    ChefDK::Generator.add_attr_to_context(:recipe_name, recipe_name)
    ChefDK::Generator.add_attr_to_context(:license, license)
  end

  context 'All is quiet' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ).converge(described_recipe)
    end

    it 'converges' do
      expect { chef_run }.to_not raise_error
    end
  end
end
