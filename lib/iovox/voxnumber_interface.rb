# frozen_string_literal: true

require 'iovox/interface'
require 'iovox/voxnumber_region'
require 'iovox/voxnumber'

module Iovox
  class VoxnumberInterface < Interface
    def get_regions(query = {})
      query[:number_type] ||= 'GEOGRAPHIC'

      result = client.get_voxnumber_regions(query: query).result

      array_wrap(result).map do |region|
        VoxnumberRegion.from_params(region)
      end
    end

    def find_by(query)
      where(query).first
    end

    def where(query = {})
      query[:req_fields] ||= 'nid,nname,lid,lname,as,cs,cc,vn,vnt,vnco,vnci,vnpd'

      response = client.get_voxnumbers(query: query)

      array_wrap(response.result).map do |voxnumber|
        Voxnumber.from_params(voxnumber)
      end
    end

    def create(item_or_items)
      items = array_wrap(item_or_items).map do |item|
        { item: item }
      end

      response = client.purchase_vox_numbers(payload: {
        request: {
          items: items,
        },
      })

      yield(response.body) if block_given?

      array_wrap(
        response.body.dig('response', 'voxnumbers', 'voxnumber')
      ).map { |result| result['full_voxnumber'] }
    end

    def delete(voxnumber_or_voxnumbers, force: false)
      voxnumbers = array_wrap(voxnumber_or_voxnumbers)

      client.delete_voxnumbers_from_account(query: {
        full_voxnumbers: voxnumbers.join(','),
        rm_if_in_use: force ? 'TRUE' : 'FALSE',
      })

      nil
    end
  end
end
