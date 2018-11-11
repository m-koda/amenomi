require 'thor'
require 'aws-sdk-elasticloadbalancing'
require 'aws-sdk-elasticloadbalancingv2'
require 'terminal-table'

module Amenomi
  class ELB < Thor
    class_option :profile, :aliases => '-p', :default => "default", :desc => "specify profile name. If you don't specify profile name, use default profile."
    class_option :region, :aliases => '-r', :default => "ap-northeast-1", :desc => "specify region. If you don't specify region, use 'ap-northeast-1'."

    no_commands do
      def elb_client
        Aws::ElasticLoadBalancing::Client.new
      end

      def elbv2_client
        Aws::ElasticLoadBalancingV2::Client.new
      end

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
    end

    desc 'list', 'list ELBs(CLB/NLB/ALB)'
    option :type, :type => :string, :required => true, :enum => ['clb', 'nlb', 'alb', 'all'], :desc => "specify ELB type."
    def list
      begin
        authenticate
        elb = elb_client
        elbv2 = elbv2_client
        case options[:type]
        when 'clb'
          lb_tables = []
          resp = elb.describe_load_balancers
          resp.load_balancer_descriptions.each do |lb|
            row = []
            row << lb.load_balancer_name
            row << lb.dns_name
            row << lb.scheme
            listeners = ""
            backends = ""
            lb.listener_descriptions.each do |list|
              listeners += "#{list.listener.protocol}(#{list.listener.load_balancer_port})\n"
              backends += "#{list.listener.instance_protocol}(#{list.listener.instance_port})\n"
            end
            row << listeners
            row << backends
            instances = ""
            lb.instances.each do |instance|
              instances += "#{instance.instance_id}\n"
            end
            row << instances
            lb_tables << row
            lb_tables << :separator
          end
          lb_tables.pop
          tables = Terminal::Table.new :headings => ['Name', 'DNS name', 'Scheme', 'Listeners', 'Backends', 'Instances'], :rows => lb_tables
          puts tables
        when 'nlb'
          p elbv2
        when 'alb'
          p elbv2
        when 'all'
          p elb
          p elbv2
        end
      rescue => e
        $stderr.puts("[ERROR] #{e.message}")
        exit 1
      end
    end

  end
end