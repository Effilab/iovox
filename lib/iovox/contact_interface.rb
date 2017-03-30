# frozen_string_literal: true

require 'iovox/interface'
require 'iovox/contact'

module Iovox
  class ContactInterface < Interface
    def get(contact_id)
      result = client.get_contact_details(query: { contact_id: contact_id }).result

      result && Contact.from_params(result)
    end

    def where(query = {})
      response =
        if query.empty?
          client.get_contacts
        else
          client.get_contacts(query: query)
        end

      load_many(response.result)
    end

    def create(contact_or_contacts)
      create_many(array_wrap(contact_or_contacts))

      nil
    end

    def update(contact_id, params)
      contact_payload = params.each_with_object({
        contact_id: contact_id
      }) do |(key, value), acc|
        key = key.to_sym

        case key
        when :id, :contact_id
          acc[:new_contact_id] = value
        else
          acc[key] = value
        end
      end

      client.update_contacts(payload: {
        request: {
          contact: contact_payload,
        },
      })

      nil
    end

    def delete(contact_id_or_contact_ids)
      contact_ids = array_wrap(contact_id_or_contact_ids)

      client.delete_contacts(query: { contact_ids: contact_ids.join(',') })

      nil
    end

    private

    def load_many(result)
      array_wrap(result).map do |res|
        Contact.from_params(res)
      end
    end

    def create_many(contacts)
      return if contacts.empty?

      request = contacts.map do |contact|
        { contact: contact.to_params }
      end

      client.create_contacts(payload: { request: request })
    end
  end
end
