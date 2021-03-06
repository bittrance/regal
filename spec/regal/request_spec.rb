require 'spec_helper'

module Regal
  describe Request do
    let :request do
      described_class.new(env, path_captures)
    end

    let :env do
      {}
    end

    let :path_captures do
      {}
    end

    describe '#env' do
      it 'returns the object given to #initialize' do
        expect(request.env).to equal(env)
      end
    end

    describe '#parameters' do
      context 'returns a hash that' do
        it 'includes query string parameters' do
          env['QUERY_STRING'] = 'hello=world'
          expect(request.parameters).to include('hello' => 'world')
        end

        it 'includes path captures' do
          path_captures[:echo] = 'polo'
          expect(request.parameters).to include(:echo => 'polo')
        end

        it 'is frozen' do
          expect { request.parameters[:new] = 'value' }.to raise_error(/can't modify frozen/)
        end
      end

      it 'only considers "&" as a parameter separator' do
        env['QUERY_STRING'] = 'a=1&b=2;c=3&d=4'
        expect(request.parameters).to include('a' => '1', 'b' => '2;c=3', 'd' => '4')
      end
    end

    describe '#headers' do
      context 'returns a hash that' do
        before do
          env['CONTENT_LENGTH'] = '123'
          env['HTTP_HOST'] = 'example.com'
          env['HTTP_CONTENT_TYPE'] = 'application/octet-stream'
          env['QUERY_STRING'] = 'hello=world'
        end

        it 'includes non-prefixed request headers' do
          expect(request.headers).to include('Content-Length' => '123')
        end

        it 'includes HTTP prefixed request headers' do
          expect(request.headers).to include(
            'Host' => 'example.com',
            'Content-Type' => 'application/octet-stream'
          )
        end

        it 'does not include non-header fields' do
          expect(request.headers).not_to have_key('Query-String')
        end

        it 'is frozen' do
          expect { request.headers['NEW'] = 'value' }.to raise_error(/can't modify frozen/)
        end
      end
    end

    describe '#attributes' do
      it 'returns a hash' do
        request.attributes[:foo] = 'bar'
        expect(request.attributes).to include(:foo => 'bar')
      end

      it 'returns a copy of the hash passed to #initialize' do
        attributes = {:foo => 'bar'}
        request = described_class.new(env, path_captures, attributes)
        expect(request.attributes).to include(:foo => 'bar')
        request.attributes[:bar] = 'foo'
        expect(attributes).not_to have_key(:bar)
      end
    end
  end
end
