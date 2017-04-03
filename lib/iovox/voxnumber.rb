# frozen_string_literal: true

require 'iovox/entity'

module Iovox
  Voxnumber = Entity.new(
    :node_id,
    :node_name,
    :link_id,
    :link_name,
    :assigned_status,
    :call_status,
    :country_code,
    :voxnumber,
    :voxnumber_type,
    :voxnumber_country,
    :voxnumber_city,
    :purchase_date,
  )
end
