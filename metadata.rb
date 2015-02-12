name             'php_fpm'
maintainer       'Ivan Chepurnyi'
maintainer_email 'ivan.chepurnyi@ecomdev.org'
license          'GPLv3'
description      'Installs/Configures PHP-FPM pools'
long_description 'Installs/Configures PHP-FPM pools'
version          '0.1.12'

depends 'php'
depends 'apt'
depends 'ecomdev_common'

%w(ubuntu debian centos).each do |os|
  supports os
end

cookbook = %w(php_fpm::default)

attribute 'php_versions',
          :display_name => 'Version Mapping',
          :description => 'Hash of php major to minor version mapping',
          :type => 'hash',
          :recipes => cookbook

attribute 'php/recompile',
          :display_name => 'Recompile PHP',
          :description => 'Shall we recompile php if the version is changed?',
          :type => 'boolean',
          :recipes => cookbook

attribute 'php/version',
          :display_name => 'PHP major version',
          :description => 'Major version of php to install',
          :type => 'string',
          :required => 'required',
          :choice => %w(5.3 5.4 5.5),
          :recipes => cookbook
