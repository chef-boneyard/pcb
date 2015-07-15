require 'spec_helper'

describe 'pcb::cookbook' do
  let(:skip_git_init) { true }
  let(:have_git) { false }
  let(:cookbook_root) { '/var/tmp' }
  let(:cookbook_name) { 'doppelgangers' }
  let(:cookbook_path_in_git_repo?) { false }
  let(:recipe_name) { 'cookbook' }
  let(:license) { 'apache2' }
  let(:copyright_holder) { 'Jimi Hendrix' }
  let(:email) { 'jimi@example.com' }

  before(:each) do
    ChefDK::Generator.add_attr_to_context(:skip_git_init, cookbook_path_in_git_repo?)
    ChefDK::Generator.add_attr_to_context(:have_git, have_git)
    ChefDK::Generator.add_attr_to_context(:cookbook_root, cookbook_root)
    ChefDK::Generator.add_attr_to_context(:cookbook_name, cookbook_name)
    ChefDK::Generator.add_attr_to_context(:recipe_name, recipe_name)
    ChefDK::Generator.add_attr_to_context(:license, license)
    ChefDK::Generator.add_attr_to_context(:copyright_holder, copyright_holder)
    ChefDK::Generator.add_attr_to_context(:email, email)
  end

  context 'Default for one of our target platforms' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ).converge(described_recipe)
    end

    it 'converges without error' do
      expect { chef_run }.to_not raise_error
    end

    # It may seem we're testing that chef works, but what we're really
    # doing is ensuring that we have 100% coverage for our build
    # cookbook's generator recipe.
    it 'creates the target cookbook directory' do
      expect(chef_run).to create_directory('/var/tmp/doppelgangers')
    end

    it 'creates the target cookbook recipes directory' do
      expect(chef_run).to create_directory('/var/tmp/doppelgangers/recipes')
    end

    it 'creates a chefignore' do
      expect(chef_run).to create_cookbook_file('/var/tmp/doppelgangers/chefignore')
    end

    it 'creates a README.md' do
      expect(chef_run).to create_template_if_missing('/var/tmp/doppelgangers/README.md')
    end

    # we know that if the generate command does not specify the
    # license option, `all_rights` is used, so let's test for a
    # non-default option like our favorite license, `apache2`. we
    # don't need to test it twice.
    it 'renders the LICENSE file from the correct template source' do
      expect(chef_run).to create_template_if_missing('/var/tmp/doppelgangers/LICENSE').with(source: 'LICENSE.apache2.erb')
    end

    it 'creates the Berksfile without a cookbook parent directory' do
      expect(chef_run).to create_template_if_missing('/var/tmp/doppelgangers/Berksfile')
        .with(variables: { cookbook_parent: nil })
    end

    it 'creates a .kitchen.yml file' do
      expect(chef_run).to create_cookbook_file('/var/tmp/doppelgangers/.kitchen.yml')
    end

    it 'includes delivery_build in the Berksfile' do
      expect(chef_run).to render_file('/var/tmp/doppelgangers/Berksfile')
        .with_content('cookbook \'delivery_build\'')
    end

    it 'creates dummy delivery-builder data bag keys' do
      expect(chef_run).to create_directory('/var/tmp/doppelgangers/data_bags/keys')
        .with(recursive: true)
      expect(chef_run).to create_file('/var/tmp/doppelgangers/data_bags/keys/delivery_builder_keys.json')
    end

    it 'creates a dummy encrypted data bag secret file' do
      expect(chef_run).to create_directory('/var/tmp/doppelgangers/secrets')
      expect(chef_run).to create_file('/var/tmp/doppelgangers/secrets/fakey-mcfakerton')
    end

    it 'creates a test cookbook for running verify phases' do
      expect(chef_run).to create_directory('/var/tmp/doppelgangers/test/fixtures/cookbooks/test/recipes')
        .with(recursive: true)
      expect(chef_run).to create_file('/var/tmp/doppelgangers/test/fixtures/cookbooks/test/metadata.rb')
      expect(chef_run).to render_file('/var/tmp/doppelgangers/test/fixtures/cookbooks/test/recipes/default.rb')
        .with_content(/delivery job verify/)
    end
  end

  context 'our parent is a cookbook project' do
    before(:each) do
      allow(PCB::Helpers).to receive(:cookbook_parent?).and_return(true)
    end

    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ).converge(described_recipe)
    end

    it 'creates the metadata.rb with delivery-truck dependency' do
      expect(chef_run).to create_template_if_missing('/var/tmp/doppelgangers/metadata.rb')
        .with(variables: { cookbook_parent: true })
      expect(chef_run).to render_file('/var/tmp/doppelgangers/metadata.rb')
        .with_content(/depends 'delivery-truck'/)
    end

    it 'creates the Berksfile with delivery-truck as a dependency from git' do
      expect(chef_run).to create_template_if_missing('/var/tmp/doppelgangers/Berksfile')
        .with(variables: { cookbook_parent: true })
      expect(chef_run).to render_file('/var/tmp/doppelgangers/Berksfile')
        .with_content(%r{cookbook 'delivery-truck',\s*git: 'https://github.com/opscode-cookbooks/delivery-truck.git'})
    end

    %w(default deploy functional lint provision publish quality security smoke syntax unit).each do |phase|
      it "creates a recipe for #{phase}" do
        expect(chef_run).to create_template_if_missing("/var/tmp/doppelgangers/recipes/#{phase}.rb")
          .with(variables: { phase: phase, cookbook_parent: true })
        expect(chef_run).to render_file("/var/tmp/doppelgangers/recipes/#{phase}.rb")
          .with_content(/include_recipe 'delivery-truck::#{phase}'/)
      end
    end
  end
end
