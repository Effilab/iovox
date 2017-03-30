# frozen_string_literal: true

require 'iovox/contact_interface'

RSpec.describe Iovox::ContactInterface, clean: true do
  let(:registry) do
    double(client: Iovox::Client.new)
  end

  let(:interface) do
    described_class.new(registry)
  end

  def mk_contact(args)
    Iovox::Contact.new(args)
  end

  def create_contact_raw(params)
    registry.client.create_contacts(payload: {
      request: {
        contact: params,
      },
    })
  end

  def raise_missing_contact_error
    raise_error(Faraday::ClientError) { |error|
      error.response[:body].dig('errors', 'error', '__content__') == 'Contact ID does not exist'
    }
  end

  describe '#get' do
    let(:contact) do
      mk_contact(id: 'test/foo', display_name: 'test/foo')
    end

    before(:each) do
      create_contact_raw(contact.to_params)
    end

    it 'can get a contact' do
      expect(interface.get(contact.id).to_h).to eq(contact.to_h)
    end
  end

  describe '#create' do
    let(:contact) do
      mk_contact(id: 'test/foo', display_name: 'test/foo')
    end

    it 'can create a contact' do
      interface.create(contact)

      expect(interface.get(contact.id).to_h).to eq(contact.to_h)
    end
  end

  describe '#update' do
    let(:contact) do
      mk_contact(id: 'test/foo', display_name: 'test/foo')
    end

    before(:each) do
      create_contact_raw(contact.to_params)
    end

    it 'can create a contact' do
      new_contact_id = 'test/bar'

      interface.update(contact.id, id: new_contact_id)

      expect { interface.get(contact.id) }.to raise_missing_contact_error

      expect(interface.get(new_contact_id).to_h).to eq(contact.merge(id: new_contact_id).to_h)
    end
  end

  describe '#delete' do
    let(:contact) do
      mk_contact(id: 'test/foo', display_name: 'test/foo')
    end

    before(:each) do
      create_contact_raw(contact.to_params)
    end

    it 'can delete a contact' do
      interface.delete(contact.id)

      expect { interface.get(contact.id) }.to raise_missing_contact_error
    end
  end
end
