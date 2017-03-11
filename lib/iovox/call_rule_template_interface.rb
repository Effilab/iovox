# frozen_string_literal: true

require 'iovox/interface'
require 'iovox/call_rule_template'

module Iovox
  class CallRuleTemplateInterface < Interface
    def get(name, link_id = nil)
      query = { template_name: name }
      query[:link_id] = link_id if link_id

      response = client.get_variable_rules_of_template(query: query).body.fetch('response')

      CallRuleTemplate.from_params(
        'rule_template_name' => name,
        'rules' => response.fetch('rules')
      )
    end
  end
end
