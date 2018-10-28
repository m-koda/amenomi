require 'thor'
require 'aws-sdk-ec2'
require 'terminal-table'

module Amenomi
  class EC2 < Thor
    STATE_HASH = {
      :stop => {
        :method => :stop_instances,
        :waiter_name => :instance_stopped,
        :display => "停止"
      },
      :start => {
        :method => :start_instances,
        :waiter_name => :instance_running,
        :display => "起動"
      },
      :terminate => {
        :method => :terminate_instances,
        :waiter_name => :instance_terminated,
        :display => "削除"
      },
    }.freeze

    class_option :profile, :aliases => '-p', :default => "default", :desc => "specify profile name. If you don't specify profile name, use default profile."
    class_option :region, :aliases => '-r', :default => "ap-northeast-1", :desc => "specify region. If you don't specify region, use 'ap-northeast-1'."

    no_commands do
      def authenticate
        aws_opts = {}
        aws_opts[:region] = options[:region]
        if options[:profile]
          credentials_opts = {}
          credentials_opts[:profile_name] = options[:profile]
          credentials = Aws::SharedCredentials.new(credentials_opts)
          aws_opts[:credentials] = credentials
        end
        Aws.config.update(aws_opts)
      end

      def change_state(ec2_client = nil, state_name = nil, instance_id = nil)
        resp = ec2_client.send(STATE_HASH[state_name][:method], {instance_ids: ["#{instance_id}"]})
        puts "EC2(#{instance_id})を#{STATE_HASH[state_name][:display]}しています..."
        ec2_client.wait_until(STATE_HASH[state_name][:waiter_name], {instance_ids: ["#{instance_id}"]})
        puts "EC2(#{instance_id})の#{STATE_HASH[state_name][:display]}が完了しました"
      end
    end

    desc 'list', 'list EC2 instances.'
    option :state, :type => :string, :desc => "specify instance state. You can specify 'running','pending','shutting-down','terminated','stopping','stopped'"
    def list
      begin
        authenticate
        ec2_client = Aws::EC2::Client.new
        ec2_opts = {}
        ec2_opts[:filters] = [{name: "instance-state-name", values: ["#{options[:state]}"]}] if options[:state]
        resp = ec2_client.describe_instances(ec2_opts)
        rows = []
        resp.reservations.each do |reserv|
          reserv.instances.each_with_index do |instance, index|
            row = []
            instance.tags.each do |tag|
              row << tag.value if tag.key == 'Name'
            end
            row << instance.instance_id
            row << instance.instance_type
            row << instance.state.name
            instance.private_ip_address.nil? ? row.push("-") : row.push(instance.private_ip_address)
            instance.public_ip_address.nil? ? row.push("-") : row.push(instance.public_ip_address)
            rows << row
            rows << :separator
          end
        end
        rows.pop
        table = Terminal::Table.new :headings => ['Name', 'Instance ID', 'Instance type', 'State', 'Private IP', 'Public IP'], :rows => rows
        puts table
      rescue => e
        $stderr.puts("[ERROR] #{e.message}")
        exit 1
      end
    end

    desc 'stop INSTANCE_ID', 'stop EC2 instance.'
    def stop(instance_id)
      begin
        authenticate
        ec2_client = Aws::EC2::Client.new
        change_state(ec2_client, :stop, instance_id)
      rescue => e
        $stderr.puts("[ERROR] #{e.message}")
        exit 1
      end
    end

    desc 'start INSTANCE_ID', 'start EC2 instance.'
    def start(instance_id)
      begin
        authenticate
        ec2_client = Aws::EC2::Client.new
        change_state(ec2_client, :start, instance_id)
      rescue => e
        $stderr.puts("[ERROR] #{e.message}")
        exit 1
      end
    end

    desc 'terminate INSTANCE_ID', 'terminate EC2 instance.'
    def terminate(instance_id)
      begin
        authenticate
        ec2_client = Aws::EC2::Client.new
        change_state(ec2_client, :terminate, instance_id)
      rescue => e
        $stderr.puts("[ERROR] #{e.message}")
        exit 1
      end
    end
  end
end
