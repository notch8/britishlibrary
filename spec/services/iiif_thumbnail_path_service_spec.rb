require 'rails_helper'

RSpec.describe IIIFThumbnailPathService do
  let(:file_set) { FileSet.new(id: 's1784k724') }
  let(:file) do
    double(id: 's1/78/4k/72/s1784k724/files/6185235a-79b2-4c29-8c24-4d6ad9b11470',
           mime_type: 'image/jpeg')
  end
  before do
    allow(ActiveFedora::Base).to receive(:find).with('s1784k724').and_return(file_set)
    allow(file_set).to receive_messages(original_file: file)
  end

  context "on a work" do
    let(:work) { build(:generic_work, thumbnail_id: 's1784k724') }
    before do
      allow(work).to receive_messages(file_sets: [file_set])
    end

    subject { described_class.call(work) }
    it { is_expected.to eq '/images/s1%2F78%2F4k%2F72%2Fs1784k724%2Ffiles%2F6185235a-79b2-4c29-8c24-4d6ad9b11470/full/300,/0/default.jpg' }
  end

  context "on a file set" do
    subject { described_class.call(file_set) }
    it { is_expected.to eq '/images/s1%2F78%2F4k%2F72%2Fs1784k724%2Ffiles%2F6185235a-79b2-4c29-8c24-4d6ad9b11470/full/300,/0/default.jpg' }
  end
end
