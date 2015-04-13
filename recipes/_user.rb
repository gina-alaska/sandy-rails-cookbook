account = data_bag_item('users', 'processing')

group 'processing' do
  gid account['gid'] || account['uid']
end

user_account 'processing' do
  gid 'processing'
  home node['sandy']['home']
  comment 'Sandy Processing'
  ssh_keys account['ssh_keys']
  ssh_keygen false
end

file ::File.join(node['sandy']['home'], '.gemrc') do
  content 'gem: --no-ri --no-rdoc --bindir /usr/bin'
end