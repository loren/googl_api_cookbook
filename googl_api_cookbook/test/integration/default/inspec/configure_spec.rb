describe file('/etc/nginx/ssl/googl.govwizely.com.crt') do
  it { is_expected.to be_owned_by 'root' }
  its('group') { is_expected.to eq 'root' }
  its('content') { is_expected.to include('MIIDwjCCAqoCCQCX9rz3cBr5rDANBgkqhkiG9w0BAQUFADCBojELMAkGA1UEBhMC') }
  its('mode') { is_expected.to eq 0600 }
end

describe file('/etc/nginx/ssl/googl.govwizely.com.key') do
  it { is_expected.to be_owned_by 'root' }
  its('group') { is_expected.to eq 'root' }
  its('content') { is_expected.to include('MIIEogIBAAKCAQEA4dFcLP0X3kni5fwIX3vfQXILw6sFQVVjMI8QfqeuVlprGr29') }
  its('mode') { is_expected.to eq 0600 }
end

describe file('/etc/profile.d/GOOGL_API_KEY.sh') do
  its('content') { is_expected.to include('export GOOGL_API_KEY="also_a_secret"') }
end

describe file('/etc/profile.d/PATH.sh') do
  its('content') { is_expected.to include('export PATH="/opt/ruby_build/builds/2.3/bin:$PATH"') }
end

describe file('/etc/logrotate.d/nginx') do
  its('content') { is_expected.to include('/var/log/nginx/*.log') }
end

describe file('/etc/logrotate.d/googl_api') do
  its('content') { is_expected.to include('/srv/googl_api/log/*.log') }
end
