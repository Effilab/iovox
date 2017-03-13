# frozen_string_literal: true

require 'thread'
require 'set'

require 'iovox/client'
require 'iovox/interface_registry'

module Iovox
  module Dump
    class Threader
      attr_reader :mutex

      def initialize(max_threads = 25)
        @mutex = Mutex.new
        @max_threads = max_threads
      end

      def synchronize(&block)
        mutex.synchronize(&block)
      end

      def concurrent(items)
        return yield(items) if @max_threads < 1

        size = items.size

        batch_size =
          if size <= @max_threads
            1
          else
            size / @max_threads
          end

        items.each_slice(batch_size).map { |batch|
          Thread.new { yield(batch) }
        }.flat_map(&:value)
      end

      def each(items, &block)
        concurrent(items) { |batch| batch.each(&block) }
      end

      def map(items, &block)
        concurrent(items) { |batch| batch.map(&block) }
      end

      def flat_map(items, &block)
        concurrent(items) { |batch| batch.flat_map(&block) }
      end
    end

    class Dump
      MAX_THREADS = 25

      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def client
        registry.client
      end

      def call
        get_nodes(get_node_ids)
      end

      def dump_raw(nodes)
        File.binwrite('dump.marshal', Marshal.dump(nodes))
      end

      def load_raw
        Marshal.load(File.binread('dump.marshal'))
      end

      def get_node_ids
        results = client.get_nodes(query: { req_fields: 'nid' }).result

        nodes = Set.new

        results.each do |result|
          nodes << result.fetch('node_id')
        end

        nodes.to_a
      end

      def get_nodes(node_ids)
        threader = Threader.new

        threader.map(node_ids) do |node_id|
          get_node(node_id)
        end
      end

      def get_node(node_id)
        registry[:node_full].get(node_id)
      end
    end

    class Restore
      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def assign_voxnumbers(nodes)
        voxnumbers = registry.client
          .get_voxnumbers(query: { assigned_status: 'UNASSIGNED' })
          .result
          .map { |result| result['voxnumber'] }

        threader = Threader.new

        threader.each(nodes) do |node|
          node.links.each do |link|
            begin
              voxnumber = threader.synchronize { voxnumbers.pop }

              next unless voxnumber

              registry[:link].attach_voxnumber(link.id, by_voxnumber: voxnumber)
            rescue => error
              threader.synchronize { p(error) }
            end
          end
        end
      end

      def call(nodes, max: 10)
        clean

        if max
          nodes = nodes.take(max)
        end

        nodes = nodes.map do |node|
          node.merge(links: node.links&.map { |link| link.merge(voxnumber: nil) })
        end

        threader = Threader.new

        threader.each(nodes) do |node|
          registry[:node_full].create(node)
        end

        assign_voxnumbers(nodes)
      end

      def clean
        clean_nodes
        clean_contacts
      end

      def clean_nodes
        node_ids = registry.client.get_nodes.result
        node_ids &&= node_ids.map { |r| r['node_id'] }.uniq

        if node_ids && !node_ids.empty?
          registry.client.delete_nodes(query: { node_ids: node_ids.join(',') })
        end
      end

      def clean_contacts
        contact_ids = registry.client.get_contacts.result
        contact_ids &&= contact_ids.select { |r| r['contact_id'] && r['assigned_status'] == 'UNASSIGNED' }.map { |r| r['contact_id'] }.uniq

        if contact_ids && !contact_ids.empty?
          registry.client.delete_contacts(query: { contact_ids: contact_ids.join(',') })
        end
      end
    end

    #class Migrator
      #attr_reader :registry

      #def initialize(registry)
        #@registry = registry
      #end

      #def clone_node(node_id, link_id = nil)
        #node = registry[:node_full].get(node_id, link_id)

        #new_node = dup_node(node)

        #registry[:node_full].create(new_node)

        #node.links.each_with_index do |link, link_index|
          #registry[:link].transfer_voxnumber(
            #link.id, new_node.links[link_index].id
          #)
        #end

        #registry[:node_full].get(new_node.id)
      #end

      #def dup_node(node)
        #new_node = node.merge(
          #id: "#{node.id}_CLONE_#{SecureRandom.uuid}"
        #)

        #new_node.links = node.links.map do |link|
          #new_link = link.merge(
            #node: new_node,
            #id: "#{link.id}_CLONE_#{SecureRandom.uuid}",
          #)

          #rules = link&.rule_template&.rules

          #if rules
            #rules = rules.map do |rule|
              #rule.merge(
                #contact: rule.contact.merge(
                  #id: "#{rule.contact.id}_CLONE_#{SecureRandom.uuid}"
                #)
              #)
            #end

            #new_link.rule_template = link.rule_template.merge(rules: rules)
          #end

          #new_link
        #end

        #new_node
      #end
    #end
  end
end
