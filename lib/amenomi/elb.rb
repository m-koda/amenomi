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
        instances = list_instances
        output_instances(instances)
      rescue => e
        $stderr.puts("[ERROR] #{e.message}")
        exit 1
      end
    end

  end
end
