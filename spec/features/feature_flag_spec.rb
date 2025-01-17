# frozen_string_literal: true

require 'rails_helper'

# TODO: fix flaky spec
# ref: https://github.com/notch8/britishlibrary/issues/419
RSpec.describe 'Admin can select feature flags', type: :feature, js: true, clean: true do
  let(:admin) { FactoryBot.create(:admin, email: 'admin@example.com', display_name: 'Adam Admin') }
  let(:account) { FactoryBot.create(:account, cname: 'example.com') }

  # rubocop:disable RSpec/LetSetup
  let!(:work) do
    create(:generic_work,
           title: ['Pandas'],
           keyword: ['red panda', 'giant panda'],
           creator: ["[{\"creator_given_name\":\"#{admin.name}\"}]"],
           user: admin)
  end

  let!(:collection) do
    create(:collection,
           title: ['Pandas'],
           description: ['Giant Pandas and Red Pandas'],
           creator: ["[{\"creator_given_name\":\"#{admin.name}\"}]"],
           user: admin,
           members: [work])
  end

  let!(:feature) { FeaturedWork.create(work_id: work.id) }

  before do
    Site.update(account: account)
  end

  # rubocop:enable RSpec/LetSetup

  context 'as a repository admin' do
    xit 'has a setting for featured works' do
      login_as admin
      visit 'admin/features'
      expect(page).to have_content 'Show featured works'
      find("tr[data-feature='show-featured-works']").find_button('off').click
      visit '/'
      expect(page).to have_content 'Recent works'
      expect(page).to have_content 'Pandas'
      expect(page).not_to have_content 'Featured items'
      expect(page).not_to have_selector(:link_or_button, 'Explore All Items')
      visit 'admin/features'
      find("tr[data-feature='show-featured-works']").find_button('on').click
      visit '/'
      expect(page).to have_content 'Featured items'
      expect(page).to have_content 'Pandas'
      expect(page).to have_selector(:link_or_button, 'Explore All Items')
    end

    xit 'has a setting for recently uploaded' do
      login_as admin
      visit 'admin/features'
      expect(page).to have_content 'Show recently uploaded'
      find("tr[data-feature='show-recently-uploaded']").find_button('off').click
      visit '/'
      expect(page).not_to have_content 'Recent works'
      expect(page).to have_content 'Pandas'
      expect(page).to have_content 'Featured items'
      expect(page).not_to have_selector(:link_or_button, 'View All Recent Additions')
      visit 'admin/features'
      find("tr[data-feature='show-recently-uploaded']").find_button('on').click
      visit '/'
      expect(page).to have_content 'Recent works'
      expect(page).to have_content 'Pandas'
      expect(page).to have_selector(:link_or_button, 'View All Recent Additions')
    end
  end

  context 'when all home tabs and share work features are turned off' do
    xit 'the page only shows the collections tab' do
      login_as admin
      visit 'admin/features'
      find("tr[data-feature='show-featured-works']").find_button('off').click
      find("tr[data-feature='show-recently-uploaded']").find_button('off').click
      find("tr[data-feature='show-featured-researcher']").find_button('off').click
      visit '/'
      expect(page).not_to have_content 'Recent works'
      expect(page).not_to have_content 'Featured researcher'
      expect(page).not_to have_content 'Featured items'
      expect(page).not_to have_content 'Share your work'
      expect(page).to have_content 'Terms of Use'
      expect(page).to have_selector(:link_or_button, 'View All Collections')
    end
  end

  context 'when featured researcher exists' do
    # rubocop:disable RSpec/ExampleLength
    xit 'shows a featured researcher section' do
      ContentBlock.create(name: 'featured_researcher', value: 'Jane Goodall')
      login_as admin
      visit 'admin/features'
      expect(page).to have_content 'Show featured researcher'
      find("tr[data-feature='show-featured-researcher']").find_button('off').click
      visit '/'
      expect(page).to have_content 'Recent works'
      expect(page).to have_content 'Pandas'
      expect(page).to have_content 'Featured items'
      expect(page).not_to have_content 'Featured researcher'
      visit 'admin/features'
      find("tr[data-feature='show-featured-researcher']").find_button('on').click
      visit '/'
      expect(page).to have_content 'Recent works'
      expect(page).to have_content 'Pandas'
      expect(page).to have_content 'Featured items'
      expect(page).to have_content 'Featured researcher'
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
