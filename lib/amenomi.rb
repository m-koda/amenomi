require 'amenomi/version'
require 'amenomi/ec2'
require 'thor'

module Amenomi
  class CLI < Thor
    desc 'ec2 [list|stop|terminate|start|restart]', 'manage EC2 instance'
    subcommand 'ec2', EC2
  end
end
