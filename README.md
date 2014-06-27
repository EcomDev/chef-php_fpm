# PHP Application Cookbook
Set of recipes that prepare full stack environment based on nginx+php-fpm. Suppports pear, composer and other nice features.

# Requirements
* Virtualbox
* Vagrant
* Vagrant plugins
    * Berkshelf (`vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1`)
    * Hostmanger plugin (`vagrant plugin install hostmanager`) (*nix only)
    * Omnibus installer (`vagrant plugin install vagrant-omnibus`)

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