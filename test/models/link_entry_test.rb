require "test_helper"

describe LinkEntry do
  it 'should not be valid without external URL' do
    e = LinkEntry.new
    _(e).wont_be :valid?
  end

  it 'should be valid with external URL' do
    e = LinkEntry.new(external_url: 'http://example.com')
    _(e).must_be :valid?
  end
end
