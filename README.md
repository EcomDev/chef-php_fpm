# PHP-FPM cookbook
Cookbook installs php from source by using official chef cookbook and provides LWRPs for php-fpm pool management. 

Notifies other cookbook about existence of fpm resource by settings shared_data to :resource/:fpm/\[pool_name\]
 
Integrates well with other cookbooks:
* vhost
* magento

# Requirements
* Virtualbox
* Vagrant
* Required vagrant plugins
    * Berkshelf (`vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1`)
* Optional vagrant plugins
    * Hostmanger plugin (`vagrant plugin install hostmanager`) (*nix only)
        
       Makes it easier to manage your hosts entries 
       
    * Omnibus installer (`vagrant plugin install vagrant-omnibus`)
       
       Automatically installs chef client
    
    * Cachier plugin (`vagrant plugin install vagrant-cachier`) 
       
       Improves Speed of virtual machine provisioning by caching repo packages and gems 

## Build Status

[![Develop Branch](https://api.travis-ci.org/EcomDev/chef-php_fpm.svg?branch=develop)](https://travis-ci.org/EcomDev/chef-php_fpm) **Next Release Branch**

[![Master Branch](https://api.travis-ci.org/EcomDev/chef-php_fpm.svg)](https://travis-ci.org/EcomDev/chef-php_fpm) **Current Stable Release**

# Supported OS
* Ubuntu 12.04, 13.02
* CentOS 6.3, 6.4, 6.5
* Debian 7.4

# LWRPs

* `php_fpm_pool`
   * :create - create a new php-fpm pool
   * :delete - deletes an existing php-fpm pool

# Lazy Loading

You don't need to include any of the cookbook recipes, in case if you are using LWRP. As soon as you call in your recipe `php_fpm_pool` it will automatically include php_fpm::fpm recipe. 

## Contributing

1. Fork it ( https://github.com/IvanChepurnyi/chef-ecomdev_common/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
