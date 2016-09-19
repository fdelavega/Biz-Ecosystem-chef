#
# Cookbook Name:: business-api-ecosystem
# Recipe:: 5.4.0_install
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

#git_repos = [{
#  'repository' => 'https://github.com/FIWARE-TMForum/business-ecosystem-rss.git'
#  'branch' => node[:rss][:branch]
#}]

wars = [{
  'url' => 'https://github.com/FIWARE-TMForum/business-ecosystem-rss/releases/download/v5.4.0/DSRevenueSharing.war',
  'name'=>  'DSRevenueSharing.war',
  'database' => node[:rss][:database],
  'root' => node[:root]
}]
# Include Glassfish
include_recipe "glassfish::default"

# Create glassfish domain
glassfish_domain "biz-domain"

# Create TMF API connection pools

# Create TMF API connection resources

package 'git' do
  action :install
end

#for repo in git_repos do
#  git '/opt/biz-ecosystem' do
#    repository repo[:repository]
#    reference repo[:branch]
#    action :sync
#  end
#end

# Download APIs war files
directory '/opt/biz-ecosystem/wars' do
  recursive true
end

for war in wars do
  remote_file '/opt/biz-ecosystem/wars/' + war[:name] do
    source war[:url]
    mode: '0755'
    action: :create
  end
end

# Create properties files for the RSS
directory '/etc/default/rss' do
  recursive true
end

template '/etc/default/rss/database.properties' do
  source 'database.properties'
  mode '0755'
end

template '/etc/default/rss/oauth.properties' do
  source 'oauth.properties'
  mode '0755'
end

# Create databases
include_recipe 'mysql'

mysql_service 'default' do
  port '3306'
  version '5.5'
  initial_root_password 'root'
  action [:create, :start]
end

for war in wars do
  execute 'create-databases' do
    command 'mysql -S /var/run/mysql-default/mysqld.sock -u root -proot -e "CREATE DATABASE IF NOT EXISTS ' + war[:database] + ';"'
  end
end

# Deploy war files
for war in wars do
  glassfish_deployable '/opt/biz-ecosystem/wars/' + war[:name] do
    action :deploy
    context_root war[:root]
  end
end

