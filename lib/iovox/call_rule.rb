# frozen_string_literal: true

require 'iovox/entity'
require 'iovox/contact'

module Iovox
  CallRule = Entity.new(
    :id,
    :type,
    :label,
    :record_call,
    :send_call_alert,
    :contact,
  ) do
    def self.from_params(params)
      new(
        id: params['rule_id'],
        type: params['rule_type'],
        label: params['rule_label'],
        record_call: params['record_call'],
        send_call_alert: params['send_call_alert'],
        contact: Contact.from_params(params['contact'])
      )
    end

    def to_params
      each_pair.with_object({}) do |(attr, value), acc|
        next if value.nil?

        case attr
        when :id, :type, :label
          acc[:"rule_#{attr}"] = value
        when :contact
          acc[:contact] = block_given? ? yield(attr, value) : value.to_params
        else
          acc[attr] = value
        end
      end
    end
  end
end
