# frozen_string_literal: true

require 'iovox/interface'
require 'iovox/node'
require 'iovox/link'

module Iovox
  class NodeInterface < Interface
    def get(node_id, link_id: nil)
      common_get(node_id, link_id) do |query|
        client.get_nodes(query: query)
      end
    end

    def get_full(node_id, link_id: nil)
      common_get(node_id, link_id) do |query|
        client.get_node_details(query: query)
      end
    end

    def where(query = {})
      response =
        if query.empty?
          client.get_nodes
        else
          client.get_nodes(query: query)
        end

      load_many(array_wrap(response.result))
    end

    def create(node_or_nodes)
      create_many(array_wrap(node_or_nodes))

      nil
    end

    def create_full(node)
      request = { node: node.to_params }

      client.create_node_full(payload: { request: request })

      nil
    end

    def update(node_id, params)
      request = {
        node: parameterize(params, update: true).merge(node_id: node_id)
      }

      client.update_nodes(payload: { request: request })

      nil
    end

    private

    def common_get(node_id, link_id)
      query = { node_id: node_id }

      query[:link_id] = link_id if link_id

      result = yield(query).result

      result && Node.from_params(result)
    end

    def load_many(results)
      memo = {}

      results.each do |result|
        node_id = result['node_id']

        if memo.key?(node_id)
          memo[node_id].links << Link.from_params(result, node: memo[node_id])
        else
          memo[node_id] = Node.from_params(result)
        end
      end

      memo.values
    end

    def parameterize(params, update: false)
      params.each_with_object({}) do |(key, value), acc|
        key = key.to_sym

        case key
        when :name then acc[:node_name] = value
        when :type then acc[:node_type] = value
        when :id, :node_id
          if update
            acc[:new_node_id] = value
          else
            acc[:node_id] = value
          end
        else
          acc[key] = value
        end
      end
    end

    def create_many(nodes)
      return if nodes.empty?

      request = nodes.map do |node|
        { node: parameterize(params, update: false) }
      end

      client.create_nodes(payload: { request: request })
    end
  end
end
