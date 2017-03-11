# frozen_string_literal: true

require 'iovox/entity'

module Iovox
  Link = Entity.new(
    :id,
    :type,
    :name,
    :node,
    :voxnumber,
    :click_to_call,
    :rule_template,
    :categories,
  ) do
    def self.from_params(params, node: nil)
      link = new(
        id: params['link_id'],
        name: params['link_name'],
        type: params['link_type'],
        voxnumber: params['voxnumber'],
        click_to_call: params['click_to_call'],
      )

      link.node = node || Node.new(
        id: params['node_id'],
        name: params['node_name'],
        type: params['node_type'],
        links: [link]
      )

      link.rule_template = load_rule_template(link, params)

      link.categories = load_categories(link, params)

      link
    end

    def self.load_rule_template(link, params)
      CallRuleTemplate.from_params(params.merge(
        'rule_template_name' => (params['rule_template_name'] || params['rule_name']),
      ))
    end

    def self.load_categories(link, params)
      array_wrap(params.dig('cats', 'cat')).map do |cat|
        Category.from_params(cat)
      end
    end

    def to_params
      params = {
        node_id: node.id,
        link_id: id,
        link_name: name,
        link_type: type,
      }

      if %w(0 1).include?(click_to_call)
        params[:click_to_call] = click_to_call
      end

      if rule_template
        params.merge!(rule_template.to_params)
      end

      if categories && !categories.empty?
        params[:categories] = categories.map do |category|
          { category: category.to_params }
        end
      end

      params
    end
  end
end
