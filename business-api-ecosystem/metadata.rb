name             "Business API Ecosystem"
maintainer       "CoNWeT"
maintainer_email "wstore@conwet.com"
license          "Apache 2.0"
description      "Installs and configures the Business API Ecosystem"
version          "5.4.0"

depends          "glassfish"
depends          "maven"
depends          "mysql", "~> 8.0"

%w{ debian ubuntu centos redhat fedora }.each do |os|
    supports os
end
