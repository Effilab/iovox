# frozen_string_literal: true

require 'iovox/interface'

RSpec.describe Iovox::Interface do
  let(:interface_class) do
    described_class.dup
  end

  let(:interface) do
    interface_class.new
  end

  describe 'access to a registry' do
    let(:registry) { double }

    describe 'at class-level' do
      it 'does not have a registry by default' do
        expect(interface_class.registry).to be_nil
      end

      it 'may have its own registry' do
        expect {
          interface_class.registry = registry
        }.to change(interface_class, :registry).from(nil).to(registry)
      end

      context 'when a subclass' do
        let(:superclass) do
          interface_class
        end

        let(:subclass) do
          Class.new(superclass)
        end

        it 'uses its superclass registry by default' do
          expect {
            superclass.registry = registry
          }.to change(subclass, :registry).from(nil).to(registry)
        end

        it 'may have its own registry' do
          expect {
            subclass.registry = registry
          }.not_to change(superclass, :registry)

          expect(subclass.registry).to be(registry)
        end
      end
    end

    describe 'at instance-level' do
      it 'uses its class registry by default' do
        expect {
          interface.class.registry = registry
        }.to change(interface, :registry).from(nil).to(registry)

        other_registry = double

        expect {
          interface.class.registry = other_registry
        }.to change(interface, :registry).from(registry).to(other_registry)
      end

      it 'may have its own registry' do
        expect {
          interface.registry = registry
        }.not_to change(interface.class, :registry)

        expect(interface.registry).to be(registry)
      end

      it 'may be initialized with a registry' do
        expect(interface_class.new(registry).registry).to be(registry)
      end
    end
  end

  describe 'access to a client' do
    let(:client) { double }
    let(:registry) { double(client: client) }

    describe 'at class-level' do
      it 'uses its registry\'s client' do
        expect {
          interface_class.registry = registry
        }.to change(interface_class, :client).from(nil).to(registry.client)
      end
    end

    describe 'at instance-level' do
      it 'uses its registry\'s client' do
        expect {
          interface.registry = registry
        }.to change(interface, :client).from(nil).to(registry.client)
      end
    end
  end
end
