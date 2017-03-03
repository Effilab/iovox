ENV['IOVOX_URL']        ||= ENV.fetch('DEV_IOVOX_URL')
ENV['IOVOX_USERNAME']   ||= ENV.fetch('DEV_IOVOX_USERNAME')
ENV['IOVOX_SECURE_KEY'] ||= ENV.fetch('DEV_IOVOX_SECURE_KEY')

require 'logger'
require 'iovox/client'

Iovox::Client.configuration[:logger] = Logger.new('log/test.log')

class Iovox::Client::TestCleaner
  attr_reader :client

  def initialize
    @client = Iovox::Client.new
  end

  def call
    if (nodes = client.get_nodes.result)
      node_ids =
        nodes
          .select { |node| node['node_id']&.start_with?('test/') }
          .map { |node| node['node_id'] }

      client.delete_nodes(query: { node_ids: node_ids.join(',') }) unless node_ids.empty?
    end

    if (contacts = client.get_contacts.result)
      contact_ids =
        contacts
          .select { |contact| contact['contact_id']&.start_with?('test/') }
          .map { |contact| contact['contact_id'] }

      client.delete_contacts(query: { contact_ids: contact_ids.join(',') }) unless contact_ids.empty?
    end
  end
end

RSpec.configure do |config|
  config.after(:all) do
    Iovox::Client::TestCleaner.new.call
  end
end
