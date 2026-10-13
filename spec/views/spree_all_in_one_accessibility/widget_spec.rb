require 'spec_helper'

RSpec.describe 'spree_all_in_one_accessibility/_widget.html.erb', type: :view do
  # Reloaded: the shared default store object keeps in-memory changes between examples.
  let(:store) { @default_store.reload }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_store).and_return(store)
    end
  end

  def render_widget
    render partial: 'spree_all_in_one_accessibility/widget'
  end

  it 'adds the free widget with the Turbo Drive compatibility script' do
    render_widget

    expect(rendered).to include('id="aioa-adawidget"')
    expect(rendered).to include('all-in-one-accessibility-js-widget-minify.js?colorcode=&amp;token=&amp;position=bottom_right')
    expect(rendered).to include('defer="defer"', 'data-turbo-permanent="true"')
    expect(rendered).to include('aioaTurboCompatibility')
  end

  it 'adds the license key of a paid plan' do
    SpreeAllInOneAccessibility::StoreSettings.new(store).update(enabled: true, license_key: 'KEY-123', domain: 'shop.example.com')

    render_widget

    expect(rendered).to include('token=KEY-123')
  end

  it 'renders nothing when the widget is disabled' do
    SpreeAllInOneAccessibility::StoreSettings.new(store).update(enabled: false, license_key: '', domain: 'shop.example.com')

    render_widget

    expect(rendered.strip).to be_empty
  end
end
