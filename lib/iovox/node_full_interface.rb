# frozen_string_literal: true

require 'iovox/interface'
require 'iovox/node'

module Iovox
  class NodeFullInterface < Interface
    def get(node_id, link_id = nil)
      query = { node_id: node_id }

      query[:link_id] = link_id if link_id

      result = client.get_node_details(query: query).result

      load_any(result)
    end

    def create(node)
      node_params = node.to_params

      client.create_node_full(payload: {
        request: {
          node: node_params,
        },
      })

      nil
    end

    private

    def load_any(result)
      node = Node.from_params(result)

      link_repo = registry[:link]

      node.links.each do |link|
        link.click_to_call = link_repo.get(link.id).click_to_call
      end

      node
    end
  end
end
