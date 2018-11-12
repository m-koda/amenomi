# Amenomi
EC2の操作を行えるコマンドラインツール
※ELBやRDSなどを追加予定

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'amenomi', git: 'https://github.com/higeojisan/amenomi.git'
```

And then execute:

    $ bundle

## Help
```
$ bundle exec amenomi help
Commands:
  amenomi ec2 [list|stop|terminate|start|restart]  # manage EC2 instance
  amenomi elb [list]                               # manage ELB
  amenomi help [COMMAND]                           # Describe available commands or one specific command
```

```
$ bundle exec amenomi help ec2
Commands:
  amenomi ec2 help [COMMAND]         # Describe subcommands or one specific subcommand
  amenomi ec2 list                   # list EC2 instances.
  amenomi ec2 restart INSTANCE_ID    # stop & start EC2 instance.
  amenomi ec2 start INSTANCE_ID      # start EC2 instance.
  amenomi ec2 stop INSTANCE_ID       # stop EC2 instance.
  amenomi ec2 terminate INSTANCE_ID  # terminate EC2 instance.

Options:
  -p, [--profile=PROFILE]  # specify profile name. If you don't specify profile name, use default profile.
                           # Default: default
  -r, [--region=REGION]    # specify region. If you don't specify region, use 'ap-northeast-1'.
                           # Default: ap-northeast-1
```

```
Commands:
  amenomi elb help [COMMAND]    # Describe subcommands or one specific subcommand
  amenomi elb list --type=TYPE  # list ELBs(CLB/NLB/ALB)

Options:
  -p, [--profile=PROFILE]  # specify profile name. If you don't specify profile name, use default profile.
                           # Default: default
  -r, [--region=REGION]    # specify region. If you don't specify region, use 'ap-northeast-1'.
                           # Default: ap-northeast-1
```
