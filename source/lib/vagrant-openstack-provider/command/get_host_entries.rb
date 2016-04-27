require 'vagrant-openstack-provider/command/openstack_command'

module VagrantPlugins
  module Openstack
    module Command
      class GetHostEntries < OpenstackCommand
        def self.synopsis
          I18n.t('vagrant_openstack.command.get_host_entries_synopsis')
        end
        def cmd(name, argv, env)
          fail Errors::NoArgRequiredForCommand, cmd: name unless argv.size == 0

          floating_ips = env[:openstack_client].nova.get_floating_ips(env)
          floating_ips.each do |floating_ip|
            if floating_ip['instance_id'] != nil
              server_details = env[:openstack_client].nova.get_server_details(env, floating_ip['instance_id'])
              name = server_details['name']
              shortname = server_details['name'].split('.')[0]

              floating_ip = ""
              server_details['addresses'].keys.each do |a|
                server_details['addresses'][a].each do |e|
                  if e['OS-EXT-IPS:type'] == 'floating'
                    floating_ip = e['addr']
                  end
                end
              end

              puts "#{floating_ip} #{name} #{shortname}"

            end
          end
        end
      end
    end
  end
end
