# frozen_string_literal: true

require 'iovox/interface'
require 'iovox/node'
require 'iovox/link'

module Iovox
  class NodeInterface < Interface
    def get(node_id, link_id = nil)
      query = { node_id: node_id }

      query[:link_id] = link_id if link_id

      result = client.get_nodes(query: query).result

      result && load_any(result)
    end

    def create(node_or_nodes)
      if !node_or_nodes.is_a?(Array)
        node_or_nodes = [node_or_nodes]
      end

      create_many(node_or_nodes)

      nil
    end

    def update(node_id, params)
      node_payload = params.each_with_object({
        node_id: node_id
      }) do |(key, value), acc|
        key = key.to_sym

        case key
        when :id, :node_id then acc[:new_node_id] = value
        when :name         then acc[:node_name] = value
        when :type         then acc[:node_type] = value
        else
          acc[key] = value
        end
      end

      client.update_nodes(payload: {
        request: {
          node: node_payload,
        },
      })

      nil
    end

    private

    def load_any(result)
      case result
      when Hash  then load_single(result)
      when Array then load_many(result)
      else raise
      end
    end

    def load_single(result)
      Node.from_params(result)
    end

    def load_many(results)
      first = results.shift

      node = load_single(first)

      results.each do |result|
        node.links << Link.from_params(result, node: node)
      end

      node
    end

    def create_many(nodes)
      return if nodes.empty?

      request = nodes.map do |node|
        {
          node: {
            node_id: node[:id],
            node_name: node[:name],
            node_type: node[:type],
          },
        }
      end

      client.create_nodes(payload: { request: request })
    end
  end
end
