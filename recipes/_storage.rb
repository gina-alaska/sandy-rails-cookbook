include_recipe 'parted'
include_recipe 'gina-gluster::client'

parted_disk '/dev/vdb' do
  label_type 'gpt'
  action :mklabel
  only_if {::File.exist?('/dev/vdb') && ::File.blockdev?('/dev/vdb')}
end

parted_disk '/dev/vdb' do
  part_type 'primary'
  part_start '2048s'
  part_end '100%'
  action :mkpart
  only_if {::File.exist?('/dev/vdb') && ::File.blockdev?('/dev/vdb')}
end

parted_disk '/dev/vdb1' do
  file_system 'ext4'
  action :mkfs
  only_if {::File.exist?('/dev/vdb1') }
end

directory '/mnt/scratch' do
  action :create
end

mount '/mnt/scratch' do
  fstype 'ext4'
  device '/dev/vdb1'
  enabled true
  only_if {::File.exist?('/dev/vdb1') }
end

directory '/mnt/scratch/workdir' do
  owner 'processing'
  group 'processing'
  action :create
end

directory '/gluster/cache' do
  recursive true
end

mount '/gluster/cache' do
  fstype 'glusterfs'
  device node['sandy']['storage']['cache']['device']
  action node['sandy']['storage']['cache']['actions']
end