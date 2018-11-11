require 'thor'
require 'aws-sdk-elasticloadbalancing'
require 'aws-sdk-elasticloadbalancingv2'
require 'terminal-table'

module Amenomi
  class ELB < Thor
    CLB_HEADINGS      = ['Name', 'DNS name', 'Scheme', 'Listeners', 'Backends', 'Instances']
    ALB_NLB_HEADINGS  = ['Name', 'DNS name', 'Scheme', 'Listeners']

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

      def get_listeners(elbv2_client, lb_arn)
        listener_opts = {load_balancer_arn: "#{lb_arn}"}
        listeners = ""
        loop do
          listener_resp = elbv2_client.describe_listeners(listener_opts)
          listener_resp.listeners.each do |listener|
            listeners += "#{listener.protocol}(#{listener.port})\n"
          end
          break if listener_resp.next_marker.nil?
          listener_opts[:marker] = listener_resp.next_marker
        end
        listeners
      end

      def get_classic_lbs
        elb = elb_client
        elb_opts = {}
        lb_tables = []
        loop do
          resp = elb.describe_load_balancers(elb_opts)
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
          break if resp.next_marker.nil?
          elb_opts[:marker] = resp.next_marker
        end
        lb_tables.pop
        lb_tables
      end

      def get_application_network_lbs(type)
        elbv2 = elbv2_client
        elbv2_opts = {}
        lb_tables = []
        loop do
          resp = elbv2.describe_load_balancers(elbv2_opts)
          resp.load_balancers.each do |lb|
            next unless lb.type == type
            row = []
            row << lb.load_balancer_name
            row << lb.dns_name
            row << lb.scheme
            lb_arn = lb.load_balancer_arn
            listeners = get_listeners(elbv2, lb_arn)
            row << listeners
            lb_tables << row
            lb_tables << :separator
          end
          break if resp.next_marker.nil?
          elbv2_opts[:marker] = resp.next_marker
        end
        lb_tables.pop
        lb_tables
      end

      def display_table(tables_array, headings)
        tables = Terminal::Table.new :headings => headings, :rows => tables_array
        puts tables
      end
    end

    desc 'list', 'list ELBs(CLB/NLB/ALB)'
    option :type, :type => :string, :required => true, :enum => ['clb', 'nlb', 'alb', 'all'], :desc => "specify ELB type."
    def list
      begin
        authenticate
        case options[:type]
        when 'clb'
          lb_tables = get_classic_lbs
          display_table(lb_tables, CLB_HEADINGS)
        when 'nlb'
          lb_tables = get_application_network_lbs("network")
          display_table(lb_tables, ALB_NLB_HEADINGS)
        when 'alb'
          lb_tables = get_application_network_lbs("application")
          display_table(lb_tables, ALB_NLB_HEADINGS)
        when 'all'
          lb_tables = []
          classic_lbs = get_classic_lbs
          unless classic_lbs.empty?
            lb_tables += classic_lbs
            lb_tables << :separator
          end
          application_lbs = get_application_network_lbs("application")
          unless application_lbs.empty?
            lb_tables += application_lbs
            lb_tables << :separator
          end
          network_lbs = get_application_network_lbs("network")
          unless network_lbs.empty?
            lb_tables += network_lbs
            lb_tables << :separator
          end
          lb_tables.pop
          display_table(lb_tables, CLB_HEADINGS)
        end
      rescue => e
        $stderr.puts("[ERROR] #{e.message}")
        exit 1
      end
    end

  end
end
