# frozen_string_literal: true

RSpec.describe 'createNodeFull', :api_audit, :api_clean do
  let(:client) do
    Iovox::Client.new
  end

  let(:common_id) { 'test/foo' }

  let(:node_params) do
    {
      node_id: common_id,
      node_name: common_id,
      node_type: common_id,

      links: {
        link: {
          link_id: common_id,
          link_name: common_id,
          link_type: common_id,

          rule_template_name: 'Call',

          rules_variable: {
            rule: {
              rule_id: 'call',
              rule_type: 'call',
              rule_label: 'Call',

              contact: contact_params,
            },
          },
        },
      },
    }
  end

  let(:contact_params) do
    {
      contact_id: common_id,
      phone_number: contact_phone_number,
    }
  end

  let(:contact_phone_number) { nil }

  context 'when contact phone_number is missing' do
    let(:contact_phone_number) { '' }

    it 'creates a node, a link and an unassigned contact without phone number' do
      response = client.create_node_full(payload: {
        request: {
          node: node_params,
        },
      })

      expect(response.body).to eq(
        'response' => {
          'node_id' => common_id,
          'links' => {
            'link' => {
              'link_id' => common_id
            },
          },
        }
      )

      link_id = response.body.dig('response', 'links', 'link', 'link_id')

      response = client.get_variable_rules_of_template(query: { link_id: link_id })

      expect(response.body).to include(
        'response' => {
          'rules' => {
            'rule' => hash_including(
              'contact' => {
                'contact_id' => '?',
                'phone_number' => '?'
              }
            ),
          },
        }
      )

      response = client.get_contacts(query: { contact_id: contact_params[:contact_id] })

      expect(response.result).to eq(
        'contact_id' => common_id,
        'display_name' => common_id,
        'assigned_status' => 'UNASSIGNED',
        'company' => nil,
        'email' => nil,
        'business_phone' => nil
      )
    end
  end

  context 'when contact phone_number is invalid' do
    let(:contact_phone_number) { '123' }

    it 'creates a node, a link and an assigned contact with an invalid phone number' do
      response = client.create_node_full(payload: {
        request: {
          node: node_params,
        },
      })

      expect(response.body).to eq(
        'response' => {
          'node_id' => common_id,
          'links' => {
            'link' => {
              'link_id' => common_id
            },
          },
        }
      )

      link_id = response.body.dig('response', 'links', 'link', 'link_id')

      response = client.get_variable_rules_of_template(query: { link_id: link_id })

      expect(response.body).to include(
        'response' => {
          'rules' => {
            'rule' => hash_including(
              'contact' => hash_including(
                'contact_id' => contact_params[:contact_id],
                'phone_number' => contact_params[:phone_number],
              )
            ),
          },
        }
      )

      response = client.get_contacts(query: { contact_id: contact_params[:contact_id] })

      expect(response.result).to eq(
        'contact_id' => common_id,
        'display_name' => common_id,
        'assigned_status' => 'ASSIGNED',
        'company' => nil,
        'email' => nil,
        'business_phone' => contact_params[:phone_number]
      )
    end
  end

  context 'when requesting a voxnumber with an unknown zipcode' do
    before do
      node_params.dig(:links, :link, :rules_variable, :rule).delete(:contact)

      node_params.dig(:links, :link).merge!(
        assign_voxnumber: {
          method: 'BY POSTCODE',
          voxnumber_country: 'FRANCE',
          postcode: '666',
        }
      )
    end

    it 'fails to create anything' do
      expect {
        client.create_node_full(payload: { request: { node: node_params } })
      }.to raise_error(
        Iovox::Middleware::ClientError,
        /There is no VoxNumber available in your account for the Postcode 666 or the fallback area/
      )

      link = client.get_links(query: { link_id: common_id }).result

      expect(link).to be_nil
    end
  end
end
