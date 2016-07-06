%w(unit lint syntax).each do |phase|
  # TODO: This works on Linux/Unix. Not Windows.
  execute "delivery job verify #{phase} --server localhost --ent test --org kitchen" do
    environment HOME: '/home/vagrant'
    cwd '/tmp/repo-data'
    user 'vagrant'
  end
end
