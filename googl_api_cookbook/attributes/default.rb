default['apt']['unattended_upgrades']['enable'] = true
default['apt']['unattended_upgrades']['allowed_origins'] = [
  '${distro_id} stable',
  '${distro_id} ${distro_codename}-security'
]

default['nginx']['sendfile'] = 'off'
default['nginx']['conf_template'] = 'googl_api_nginx.conf.erb'
default['nginx']['conf_cookbook'] = 'googl_api_cookbook'
default['nginx']['install_method'] = 'source'
default['nginx']['version'] = '1.11.0'
force_default['nginx']['source']['checksum'] = '6ca0e7bf540cdae387ce9470568c2c3a826bc7e7f12def1ae7d20b66f4065a99'

default['deploy']['root_directory'] = '/srv'
