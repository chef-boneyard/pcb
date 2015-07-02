
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

# cookbook root dir
directory cookbook_dir

# metadata.rb
template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
  variables cookbook_parent: PCB::Helper.cookbook_parent?
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

# Berksfile
template "#{cookbook_dir}/Berksfile" do
  helpers(ChefDK::Generator::TemplateHelper)
  variables cookbook_parent: PCB::Helper.cookbook_parent?
  action :create_if_missing
end

# Recipes
directory "#{cookbook_dir}/recipes"

%w(default deploy functional lint provision publish quality security smoke syntax unit).each do |phase|
  template "#{cookbook_dir}/recipes/#{phase}.rb" do
    source 'recipe.rb.erb'
    helpers(ChefDK::Generator::TemplateHelper)
    variables phase: phase, cookbook_parent: PCB::Helper.cookbook_parent?
    action :create_if_missing
  end
end
