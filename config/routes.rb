Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do
    resource :all_in_one_accessibility, only: %i[edit update],
                                        controller: 'all_in_one_accessibility',
                                        path: 'all-in-one-accessibility'
  end
end
