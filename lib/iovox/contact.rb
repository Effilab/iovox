# frozen_string_literal: true

require 'iovox/entity'

module Iovox
  Contact = Entity.new(
    :id,
    :display_name,
    :company,
    :email,
    :business_phone,
    :assigned_status,

    :email2,
    :title,
    :business_fax,
    :work_address_1,
    :work_address_2,
    :work_city,
    :work_postcode,
    :work_country,
    :home_phone,
    :mobile_phone,
    :home_address_1,
    :home_address_2,
    :home_city,
    :home_postcode,
    :home_country,
    :notes
  ) do
      alias_method :phone_number, :business_phone
      alias_method :phone_number=, :business_phone=

      def self.from_params(params)
        new({ id: params['contact_id'] }.merge(params))
      end

      def to_params(with_phone_number: false)
        each_pair.with_object({}) do |(attr, value), acc|
          next if value.nil?

          case attr
          when :id
            acc[:contact_id] = value
          else
            acc[attr] = value
          end

          if with_phone_number
            acc[:phone_number] = phone_number
          end
        end
      end
    end
end
