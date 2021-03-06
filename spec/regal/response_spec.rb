module Regal
  describe Response do
    let :response do
      described_class.new
    end

    context 'used as a response 3-tuple' do
      before do
        response.body = 'hello'
      end

      it 'implements #to_ary' do
        status, headers, body = response
        expect(status).to eq(200)
        expect(headers).to eq({})
        expect(body).to eq(%w[hello])
      end

      it 'implements #[]' do
        expect(response[0]).to eq(200)
        expect(response[1]).to eq({})
        expect(response[2]).to eq(%w[hello])
        expect(response[3]).to be_nil
      end

      it 'implements #[]=' do
        response[2] = %w[foo]
        expect(response[2]).to eq(%w[foo])
      end

      it 'ignores indexes over 2' do
        response[10] = 10
        expect(response.to_a.size).to eq(3)
      end

      it 'wraps string bodies in an array' do
        expect(response[2]).to eq(%w[hello])
      end

      it 'leaves objects that respond to #each as-is' do
        response.body = %w[one two three]
        expect(response[2]).to eq(%w[one two three])
      end

      it 'leaves Rack incompatible bodies as-is' do
        response.body = 123
        expect(response[2]).to eq(123)
      end

      it 'uses the raw body if set' do
        response.raw_body = %w[one two]
        response.body = 'three'
        expect(response[2]).to eq(%w[one two])
      end
    end

    describe '#no_body' do
      it 'sets the raw body to an empty array' do
        response.no_body
        expect(response[2]).to eq([])
      end
    end
  end
end
