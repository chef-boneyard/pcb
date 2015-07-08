module PCB
  module Helpers
    # cookbook_parent? is used to pass in a variable to templates if
    # we're in a build cookbook for a cookbook project, e.g., so we
    # can get delivery-truck and delivery-sugar dependencies via berks
    # from github since they're not published to supermarket.
    def self.cookbook_parent?(cookbook_root)
      # we're being generated in project/.delivery/build-cookbook, so
      # look for ../../metadata.json or .rb
      parent_project = File.expand_path(File.join(cookbook_root, '..', '..'))
      return true if File.exist?(File.join(parent_project, 'metadata.rb'))
      return true if File.exist?(File.join(parent_project, 'metadata.json'))
    end
  end
end unless defined?(PCB::Helpers)
