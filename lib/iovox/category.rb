# frozen_string_literal: true

require 'iovox/entity'

module Iovox
  Category = Entity.new(
    :id,
    :label,
    :value,
  ) do
    def self.from_params(params)
      new(
        id: params['category_id'],
        label: params['label'],
        value: params['value'],
      )
    end

    def to_params
      params = {
        label: label,
        value: value,
      }

      params[:category_id] = id if id

      params
    end
  end
end
