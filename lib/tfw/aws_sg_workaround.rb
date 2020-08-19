# frozen_string_literal: true

module TFW
  # This module is a workaround the issue that when using json some fields that are optional become required
  # https://github.com/hashicorp/terraform/issues/23347
  module AwsSgWorkaround
    module_function

    def fix(stack_json)
      stack = JSON.parse stack_json
      return stack.to_json unless stack.key? 'resource'

      r = stack['resource']
      return stack.to_json unless r.key? 'aws_security_group'

      asg = r['aws_security_group']
      asg.each do |_, sg|
        replace_and_fill sg, 'egress' if sg.key? 'egress'
        replace_and_fill sg, 'ingress' if sg.key? 'ingress'
      end
      stack.to_json
    end

    def replace_and_fill(obj, key)
      backup = obj[key]
      fill_fields(backup)
      obj[key] = [backup]
    end

    def fill_fields(obj)
      obj['description'] = '' unless obj.key? 'description'
      obj['security_groups'] = [] unless obj.key? 'security_groups'
      obj['self'] = false unless obj.key? 'self'
      obj['ipv6_cidr_blocks'] = [] unless obj.key? 'ipv6_cidr_blocks'
      obj['prefix_list_ids'] = [] unless obj.key? 'prefix_list_ids'
    end
  end
end
