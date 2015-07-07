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
