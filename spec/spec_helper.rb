#
# PHP-FPM Cookbook - PHP-FPM Chef Cookbook to allow building easily vagrant
# environment
# Copyright (C) 2014 Ivan Chepurnyi <ivan.chepurnyi@ecomdev.org>, EcomDev B.V.
#
# This file is part of PHP-FPM Cookbook.
#
# PHP-FPM Cookbook is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# PHP-FPM Cookbook is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with PHP-FPM Cookbook.  If not, see <http://www.gnu.org/licenses/>.
#
require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'

module SpecHelper
  def stub_include (additional_recipes = [])
    # Don't worry about external cookbook dependencies
    allow_any_instance_of(Chef::Cookbook::Metadata).to receive(:depends)

    # Test each recipe in isolation, regardless of includes
    @included_recipes = []
    allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipe?).and_return(false)

    allow_any_instance_of(Chef::RunContext).to receive(:include_recipe).with(described_recipe).and_call_original

    allow_any_instance_of(Chef::RunContext).to receive(:include_recipe) do |run_context, recipe_name|
      if recipe_name.is_a?(String)
        allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipe?).with(recipe_name).and_return(true)
        @included_recipes.push(recipe_name)
        if additional_recipes.include?(recipe_name)
          run_context.load_recipe(recipe_name)
        end
      else
        recipe_name.flatten.each do |sub_recipe_name|
          run_context.include_recipe(sub_recipe_name)
        end
      end

      @included_recipes
    end

    allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipes).and_return(@included_recipes)
  end

  def stub_exist (path, result = true, call_original_stub = false)
    if call_original_stub
      allow(File).to receive(:exist?).with(:anything).and_call_original
    end
    allow(File).to receive(:exist?).with(path).and_return(result)
  end

  def stub_dir_glob(glob, result)
    allow(Dir).to receive(:glob).with(:anything).and_call_original
    allow(Dir).to receive(:glob).with(glob).and_return(result)
  end

  def stub_dir_existence(chef_run, exist=true)
    stub_exist(chef_run.node['php']['fpm']['conf_dir'], exist, true)
    stub_exist(chef_run.node['php']['fpm']['pool_dir'], exist)
    stub_exist(chef_run.node['php']['fpm']['log_dir'], exist)
    stub_exist(chef_run.node['php']['fpm']['run_dir'], exist)
  end

  def stub_php_vars(node, version_alias='5.test', version='5.1.0', checksum='test1', bin='test-php-bin')
    node.set['php_versions'][version_alias]['version'] = version
    node.set['php_versions'][version_alias]['checksum'] = checksum
    node.set['php']['major_version'] = version_alias
    node.set['php']['bin'] = bin
  end

  # @return [self]
  def converge
    chef_run.converge(described_recipe) do
      yield chef_run.node, chef_run if block_given?
    end

    self
  end

  # @return [RSpec::Matchers::BuiltIn::Match]
  def line_starts_with(string)
    RSpec::Matchers::BuiltIn::Match.new(Regexp.new('^' + Regexp.escape(string).tr_s('\\ ', '\\s'), Regexp::MULTILINE))
  end

  # @return [RSpec::Matchers::BuiltIn::Match]
  def line_ends_with(string)
    RSpec::Matchers::BuiltIn::Match.new(Regexp.new('^' + Regexp.escape(string).tr_s('\\ ', '\\s'), Regexp::MULTILINE))
  end

  # @return [RSpec::Matchers::BuiltIn::Match]
  def line_contains(string)
    RSpec::Matchers::BuiltIn::Match.new(Regexp.new('^.*' + Regexp.escape(string).tr_s('\\ ', '\\s') + '.*$', Regexp::MULTILINE))
  end

  # @return [RSpec::Matchers::BuiltIn::Match]
  def line_matches(string)
    RSpec::Matchers::BuiltIn::Match.new(Regexp.new('^\s*' + Regexp.escape(string).tr_s('\\ ', '\\s') + '\s*$', Regexp::MULTILINE))
  end


  # @return [ChefSpec::Runner]
  def converged
    if chef_run.compiling?
      converge do |node, runner|
        yield node, runner if block_given?
      end
    end

    chef_run
  end
end

class SpecPlatforms
  def self.versions
    {
        'ubuntu' => ['10.04', '12.04', '13.10', '14.04'],
        'debian' => ['6.0.5', '7.2', '7.4'],
        'freebsd' => ['9.2'],
        'centos' => ['5.8','6.4', '6.5'],
        'redhat' => ['5.6', '6.3', '6.4'],
        'fedora' => ['18', '19', '20']
    }
  end

  def self.filtered(latest=false, platforms = [])
    os_hash = Hash.new
    all_os = versions

    if platforms.count == 0
       all_os.keys.each { |key| platforms.push(key) }
    end

    platforms.each do |platform|
      if all_os.has_key?(platform)
        if latest
          os_hash[platform] = Array(all_os[platform]).last
        else
          os_hash[platform] = all_os[platform]
        end
      end
    end
    os_hash
  end

  def self.platform_families(latest=true)
    self.filtered(latest, %w(fedora redhat debian))
  end
end

ChefSpec::Coverage.start!