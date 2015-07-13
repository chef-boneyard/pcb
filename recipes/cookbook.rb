
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

# cookbook root dir
directory cookbook_dir

# metadata.rb
template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
  variables cookbook_parent: PCB::Helpers.cookbook_parent?(cookbook_dir)
  action :create_if_missing
end

# README
template "#{cookbook_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# LICENSE
template "#{cookbook_dir}/LICENSE" do
  source "LICENSE.#{context.license}.erb"
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# chefignore
cookbook_file "#{cookbook_dir}/chefignore"

# Berksfile
template "#{cookbook_dir}/Berksfile" do
  helpers(ChefDK::Generator::TemplateHelper)
  variables cookbook_parent: PCB::Helpers.cookbook_parent?(cookbook_dir)
  action :create_if_missing
end

# Recipes
directory "#{cookbook_dir}/recipes"

%w(default deploy functional lint provision publish quality security smoke syntax unit).each do |phase|
  template "#{cookbook_dir}/recipes/#{phase}.rb" do
    source 'recipe.rb.erb'
    helpers(ChefDK::Generator::TemplateHelper)
    variables phase: phase, cookbook_parent: PCB::Helpers.cookbook_parent?(cookbook_dir)
    action :create_if_missing
  end
end

# Test Kitchen build node
cookbook_file "#{cookbook_dir}/.kitchen.yml"

directory "#{cookbook_dir}/data_bags/keys" do
  recursive true
end

file "#{cookbook_dir}/data_bags/keys/delivery_builder_keys.json" do
  content '{"id": "delivery_builder_keys"}'
end

directory "#{cookbook_dir}/secrets"

file "#{cookbook_dir}/secrets/fakey-mcfakerton"

directory "#{cookbook_dir}/test/fixtures/cookbooks/test/recipes" do
  recursive true
end

file "#{cookbook_dir}/test/fixtures/cookbooks/test/metadata.rb" do
  content %(name 'test'
version '0.1.0')
end

cookbook_file "#{cookbook_dir}/test/fixtures/cookbooks/test/recipes/default.rb" do
  source 'test-fixture-recipe.rb'
end
