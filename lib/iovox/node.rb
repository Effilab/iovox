# frozen_string_literal: true

require 'iovox/entity'
require 'iovox/category'
require 'iovox/link'

module Iovox
  Node = Entity.new(
    :id,
    :name,
    :type,
    :links,
    :categories
  ) do
    def self.from_params(params)
      node = new(
        id: params['node_id'],
        name: params['node_name'],
        type: params['node_type']
      )

      node.links = load_links(node, params)
      node.categories = load_categories(node, params)

      node
    end

    def self.load_links(node, params)
      links = array_wrap(params.dig('links', 'link')).map do |link_params|
        Link.from_params(link_params, node: node)
      end

      if params.key?('link_id')
        links << Link.from_params(params, node: node)
      end

      links
    end

    def self.load_categories(_node, params)
      array_wrap(params.dig('cats', 'cat')).map do |cat|
        Category.from_params(cat)
      end
    end

    def to_params
      params = {
        node_id: id,
        node_name: name,
        node_type: type,
      }

      if links && !links.empty?
        params[:links] = links.map do |link|
          { link: link.to_params }
        end
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
