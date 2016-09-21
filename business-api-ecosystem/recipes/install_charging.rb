#
# Cookbook Name:: business-api-ecosystem
# Recipe:: install_charging
#
# Copyright 2016, CoNWeT Lab., Universidad PolitÃ©cnica de Madrid
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'

include_recipe "build-essential"
include_recipe "poise-python"

# Clone business ecosystem charging repo
git "/opt/biz-ecosystem/business-ecosystem-charging-backend" do
  repository "https://github.com/FIWARE-TMForum/business-ecosystem-charging-backend.git"
  reference "v5.4.0"
  action :sync
end

# Install system dependencies
pkgs = value_for_platform_family(
   "debian" => ["xvfb", "libssl-dev", "libffi-dev", "python-dev"],
   "rhel" => ["xorg-x11-server-Xvfb", "libffi-devel",  "python-devel",  "openssl-devel", "gcc"],
   "fedora" => ["xorg-x11-server-Xvfb", "libffi-devel",  "python-devel",  "openssl-devel", "gcc"],
   "default" => ["xvfb", "libssl-dev", "libffi-dev", "python-dev"]
)

for pkg in pkgs do
  package pkg do
    action :install
  end
end

case node[:platform_family]
when "debian"
  package "wkhtmltopdf" do
    action :install
  end

when "rhel", "fedora"
  wk_file = "/tmp/wkhtmltox-0.12.1_linux-centos7-amd64.rpm"

  remote_file wk_file do
    source "http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-centos7-amd64.rpm"
  end

  rpm_package wk_file do
    source wk_file
    action :install
  end

else
  Chef::Log.warn("No support for wkhtmltopdf in your system")
end

# Install python dependencies
python_dep = [{
  'name' => 'pymongo',
  'version' => '3.0.3'
}, {
  'name' => 'paypalrestsdk',
  'version' => '1.11.0'
}, {
  'name' => 'nose',
  'version' => '1.3.6'
}, {
  'name' => 'django-nose',
  'version' => '1.4'
}, {
  'name' => 'django-crontab',
  'version' => '0.6.0'
}, {
  'name' => 'requests',
  'version' => '2.8.1'
}, {
  'name' => 'requests[security]',
  'version' => '2.8.1'
}, {
  'name' => 'regex',
  'version' => '2015.10.22'
}, {
  'name' => 'six',
  'version' => '1.10.0'
}]

for dep in python_dep do
  python_package dep['name'] do
    version dep['version']
  end
end

# Install python dependencies comming from github
python_git_dep = [{
  'name' => 'django',
  'url' => 'https://github.com/django-nonrel/django.git',
  'branch' => 'nonrel-1.6'
}, {
  'name' => 'djangotoolbox',
  'url' => 'https://github.com/django-nonrel/djangotoolbox.git',
  'branch' => 'master'
}, {
  'name' => 'mongodbengine',
  'url' => 'https://github.com/django-nonrel/mongodb-engine.git',
  'branch' => 'master'
}]

for dep in python_git_dep do

  python_execute 'install ' + dep['name'] do
    action :nothing
    command '-m pip install'
    cwd '/opt/biz-ecosystem/' + dep['name']
  end

  git '/opt/biz-ecosystem/' + dep['name'] do
    repository dep['url']
    reference dep['branch']
    notifies :run, 'python_execute[install ' + dep['name'] + ']', :immediately
  end
end

# Deploy templates
template '/opt/biz-ecosystem/business-ecosystem-charging-backend/src/settings.py' do
  source 'settings.py.erb'
  mode '0755'
end

template '/opt/biz-ecosystem/business-ecosystem-charging-backend/src/services_settings.py' do
  source 'services_settings.py.erb'
  mode '0755'
end

template '/opt/biz-ecosystem/business-ecosystem-charging-backend/src/wstore/charging_engine/payment_client/paypal_client.py' do
  source 'paypal_client.py.erb'
  mode '0755'
end

template '/etc/init.d/business-charging' do
  source 'business-charging.erb'
  mode '0755'
end

# Create sites
template '/opt/biz-ecosystem/createsites.js' do
  source 'createsites.js.erb'
  mode '0755'
end

execute 'create sites' do
  command 'mongo /opt/biz-ecosystem/createsites.js'
end

# Run the charging backend
service 'business-charging' do
  action :restart
end

