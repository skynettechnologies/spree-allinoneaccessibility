require 'unit_helper'

RSpec.describe SpreeAllInOneAccessibility::Domain do
  describe '.normalize' do
    {
      'example.com' => 'example.com',
      ' WWW.Example.COM ' => 'www.example.com',
      'https://shop.example.com/products?page=2#top' => 'shop.example.com',
      'http://localhost:3000' => 'localhost',
      'shop.example.com:8443' => 'shop.example.com',
      'xn--bcher-kva.example' => 'xn--bcher-kva.example'
    }.each do |input, expected|
      it "turns #{input.inspect} into #{expected.inspect}" do
        expect(described_class.normalize(input)).to eq(expected)
      end
    end

    [nil, '', '   ', 'not a domain', 'https://', '-example.com', 'exa_mple.com', 'user@example.com',
     'example..com', "#{'a' * 250}.com"].each do |input|
      it "rejects #{input.inspect}" do
        expect(described_class.normalize(input)).to be_nil
      end
    end
  end
end
