# frozen_string_literal: true

require 'iovox/interface'
require 'iovox/link'

module Iovox
  class LinkInterface < Interface
    def get(link_id)
      query = {
        link_id: link_id,
        req_fields: %w(nid nn nt lid ln lt vn rn c2c).join(','),
      }

      result = client.get_links(query: query).result

      result && load_any(result)
    end

    def create(link_or_links)
      if !link_or_links.is_a?(Array)
        link_or_links = [link_or_links]
      end

      create_many(link_or_links)

      nil
    end

    def update(link_id, params)
      link_payload = params.each_with_object({
        link_id: link_id
      }) do |(key, value), acc|
        key = key.to_sym

        case key
        when :id, :link_id then acc[:new_link_id] = value
        when :name         then acc[:link_name] = value
        when :type         then acc[:link_type] = value
        else
          acc[key] = value
        end
      end

      client.update_links(payload: {
        request: {
          link: link_payload,
        },
      })

      nil
    end

    def detach_voxnumber(link_id)
      client.remove_voxnumber_from_link(payload: {
        request: {
          link_id: link_id,
        },
      })

      nil
    end

    def attach_voxnumber(link_id, opts)
      method, arg = opts.first

      case method
      when :by_voxnumber
        attach_voxnumber_by_voxnumber(link_id, arg)
      when :by_postcode
        attach_voxnumber_by_postcode(link_id, arg)
      else
        raise NoMethodError, "Cannot attach voxnumber #{method}"
      end

      nil
    end

    def transfer_voxnumber(link_id, new_link_id)
      voxnumber = get(link_id).voxnumber

      if voxnumber && !voxnumber.empty?
        detach_voxnumber(link_id)
        attach_voxnumber(new_link_id, by_voxnumber: voxnumber)
      end

      nil
    end

    def attach_call_rule_template(link_id_or_link_ids, rule_template)
      link_ids =
        case link_id_or_link_ids
        when Array
          link_id_or_link_ids.map { |link_id| { link_id: link_id } }
        else
          [{ link_id: link_id_or_link_ids }]
        end

      request = {
        link_ids: link_ids,
        overwrite_existing: 'FALSE',
      }.merge(rule_template.to_params(name_key: :template_name))

      client.attach_rule_template_to_links(payload: { request: request })

      nil
    end

    private

    def load_any(result)
      Link.from_params(result)
    end

    def create_many(links)
      return if links.empty?

      request = links.map do |link|
        { link: link.to_params }
      end

      client.create_links(payload: { request: request })
    end

    def attach_voxnumber_by_voxnumber(link_id, voxnumber)
      client.attach_voxnumber_to_link(payload: {
        request: {
          link: {
            link_id: link_id,
            method: 'BY VOXNUMBER',
            full_voxnumber: voxnumber,
          },
        },
      })
    end

    def attach_voxnumber_by_postcode(link_id, opts)
      link = {
        link_id: link_id,
        method: 'BY POSTCODE',
        voxnumber_country: opts.fetch(:country),
        postcode: opts.fetch(:postcode),
      }

      if opts[:fallback_distance]
        link[:fallback_area_distance] = opts[:fallback_distance]
      end

      client.attach_voxnumber_to_link(payload: {
        request: {
          link: link,
        },
      })
    end
  end
end
