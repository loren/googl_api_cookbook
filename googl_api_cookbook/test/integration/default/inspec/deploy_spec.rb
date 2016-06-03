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

describe file('/etc/logrotate.d/googl_api') do
  its('content') { is_expected.to include('/srv/googl_api/log/*.log') }
end

describe service 'nginx' do
  it { is_expected.to be_enabled }
  it { is_expected.to be_running }
end

describe service 'googl_api' do
  it { is_expected.to be_enabled }
  it { is_expected.to be_running }
end

describe command 'curl -k https://localhost/shorten' do
  its('stdout') { is_expected.to include('missing_parameters') }
end

describe port 443 do
  it { is_expected.to be_listening }
end

describe port 80 do
  it { is_expected.to_not be_listening }
end

describe file('/srv/googl_api/config/secrets.yml') do
  its('content') { is_expected.to include('secret_key_base: also_a_secret') }
end

describe command '/opt/ruby_build/builds/2.3/bin/ruby -v' do
  its('stdout') { is_expected.to include('ruby 2.3') }
end
