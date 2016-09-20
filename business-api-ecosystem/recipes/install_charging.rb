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
git "/opt/biz-ecosystem" do
  repository "https://github.com/FIWARE-TMForum/business-ecosystem-charging-backend.git"
  reference "v5.4.0"
  action :sync
end

# Create a virtualenv
python_virtualenv "/opt/biz-ecosystem/business-ecosystem-charging-backend/virtenv"

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
  python_package dep[:name] do
    version dep[:version]
  end
end
