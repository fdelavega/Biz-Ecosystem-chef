#
# Cookbook Name:: business_api_ecosystem
# Recipe:: install_proxy
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

# git clone
git "/opt/biz-ecosystem/business-ecosystem-logic-proxy" do
  repository "https://github.com/FIWARE-TMForum/business-ecosystem-logic-proxy.git"
  revision node[:biz][:version]
  action :sync
end

include_recipe "nodejs::nodejs_from_binary" 
include_recipe "nodejs::npm"

# npm install
nodejs_npm "biz-ecosys-logic-proxy" do
  path "/opt/biz-ecosystem/business-ecosystem-logic-proxy/"
  json true
end

template "/opt/biz-ecosystem/business-ecosystem-logic-proxy/config.js" do
  source node[:biz][:proxy][:conf]
end

template "/etc/init.d/business-proxy" do
  source "business-proxy.erb"
  mode "0755"
end

