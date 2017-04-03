# frozen_string_literal: true

require 'iovox/voxnumber_interface'

RSpec.describe Iovox::VoxnumberInterface do
  let(:registry) do
    double(client: Iovox::Client.new)
  end

  let(:client) { registry.client }

  let(:interface) do
    described_class.new(registry)
  end

  let(:additional_information) do
    {
      firstname: 'N/A',
      lastname: 'N/A',
      company: 'N/A',
      street: 'N/A',
      building_number: '1',
      city: 'N/A',
      zipcode: 'N/A',
    }
  end

  describe '#get_regions' do
    it 'can query voxnumber regions, using GEOGRAPHIC number_type by default' do
      expect(client).to receive(:get_voxnumber_regions).with(
        query: hash_including(number_type: 'GEOGRAPHIC')
      ).and_call_original

      regions = interface.get_regions(limit: 2, country_code: '33')

      expect(regions).to all(
        have_attributes(
          area_code: kind_of(String),
          country_code: '33',
          country_name: 'FRANCE',
          city_name: kind_of(String),
          require_purchase_info: kind_of(String),
        )
      )
    end
  end

  describe '#where' do
    # TODO: we should create voxnumbers before querying them
    it 'can query voxnumbers' do
      voxnumbers = interface.where(limit: 2, assigned_status: 'UNASSIGNED', voxnumber_country: 'FRANCE')

      expect(voxnumbers.size).to eq(2)

      expect(voxnumbers).to all(
        have_attributes(
          assigned_status: 'UNASSIGNED',
          voxnumber_country: 'FRANCE',
          voxnumber: kind_of(String)
        )
      )
    end
  end

  describe '#create / #delete' do
    def build_params(regions)
      regions.map do |region|
        base = {
          number_type: 'GEOGRAPHIC',
          area_code: region.area_code,
          country_code: region.country_code,
          quantity: 1,
        }

        if region.require_purchase_info == '1'
          base[:additional_information] = additional_information
        end

        base
      end
    end

    def create_voxnumbers(&block)
      regions = interface.get_regions(limit: 2, country_code: '33')

      params = build_params(regions)

      interface.create(params, &block)
    end

    it 'can create new voxnumber' do
      voxnumbers = create_voxnumbers

      expect(voxnumbers.size).to eq(2)

      expect(voxnumbers).to all(be_kind_of(String))
    end

    it 'can delete a voxnumber' do
      voxnumber = create_voxnumbers.first

      expect(interface.where(voxnumber: voxnumber)).not_to be_empty

      interface.delete(voxnumber)

      expect(interface.where(voxnumber: voxnumber)).to be_empty
    end
  end
end
