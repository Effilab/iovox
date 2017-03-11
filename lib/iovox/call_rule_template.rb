# frozen_string_literal: true

require 'iovox/entity'
require 'iovox/call_rule'

module Iovox
  CallRuleTemplate = Entity.new(
    :name,
    :rules,
  ) do
    def self.from_params(params)
      rule_template = new(name: params['rule_template_name'])

      rule_template.rules = load_rules(rule_template, params)

      rule_template
    end

    def self.load_rules(rule_template, params)
      array_wrap(params.dig('rules', 'rule')).map do |rule_params|
        CallRule.from_params(rule_params)
      end
    end

    def to_params(name_key: :rule_template_name)
      params = { name_key => name }

      if rules && !rules.empty?
        params[:rules_variable] = rules.map do |call_rule|
          rule = call_rule.to_params do |relation, value|
            case relation
            when :contact then value.to_params(with_phone_number: true)
            else value.to_params
            end
          end

          { rule: rule }
        end
      end

      params
    end
  end
end
