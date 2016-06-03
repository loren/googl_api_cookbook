default['apt']['unattended_upgrades']['enable'] = true
default['apt']['unattended_upgrades']['allowed_origins'] = [
  '${distro_id} stable',
  '${distro_id} ${distro_codename}-security'
]

default['deploy']['root_directory'] = '/srv'
