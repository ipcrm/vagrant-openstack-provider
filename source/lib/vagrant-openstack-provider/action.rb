require "pathname"

require "vagrant/action/builder"

module VagrantPlugins
  module Openstack
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to destroy the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use MessageNotCreated
            else
              b2.use DeleteServer
            end
          end
        end
      end

      # This action is called when `vagrant provision` is called.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use MessageNotCreated
            else
              b2.use Provision
              b2.use SyncFolders
            end
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use ReadState
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use MessageNotCreated
            else
              b2.use SSHExec
            end
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use MessageNotCreated
            else
              b2.use SSHRun
            end
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack

          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use Provision
              b2.use SyncFolders
              b2.use CreateServer
            else
              b2.use MessageAlreadyCreated
            end
          end
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use MessageNotCreated
            else
              b2.use StopServer
            end
          end
        end
      end

      # This is the action that is primarily responsible for suspending
      # the virtual machine.
      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use MessageNotCreated
            elsif env[:machine_state_id] === :suspended
              b2.use MessageAlreadySuspended
            else
              b2.use Suspend
            end
          end
        end
      end

      # This is the action that is primarily responsible for resuming
      # suspended machines.
      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenstack
          b.use Call, ReadState do |env, b2|
            if env[:machine_state_id] === :not_created
              b2.use MessageNotCreated
            else
              b2.use Resume
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :ConnectOpenstack, action_root.join("connect_openstack")
      autoload :CreateServer, action_root.join("create_server")
      autoload :DeleteServer, action_root.join("delete_server")
      autoload :StopServer, action_root.join("stop_server")
      autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      autoload :MessageAlreadySuspended, action_root.join("message_already_suspended")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :ReadState, action_root.join("read_state")
      autoload :SyncFolders, action_root.join("sync_folders")
      autoload :Suspend, action_root.join("suspend")
      autoload :Resume, action_root.join("resume")
    end
  end
end
