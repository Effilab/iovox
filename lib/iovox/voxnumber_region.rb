# frozen_string_literal: true

require 'iovox/entity'

module Iovox
  VoxnumberRegion = Entity.new(
    :area_code,
    :country_code,
    :country_name,
    :state_name,
    :city_name,
    :require_purchase_info,
  )
end
