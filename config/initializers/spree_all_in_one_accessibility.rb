# Runs after Spree Admin and Spree Storefront have set up their navigation and partial registries.
Rails.application.config.after_initialize do
  Spree.admin.navigation.settings.add :all_in_one_accessibility,
                                      label: 'admin.all_in_one_accessibility.nav_label',
                                      url: :edit_admin_all_in_one_accessibility_path,
                                      icon: 'accessible',
                                      position: 62,
                                      active: -> { controller_name == 'all_in_one_accessibility' },
                                      if: -> { can?(:update, current_store) }

  # Rails Storefront (spree_storefront). Headless storefronts add the script tag themselves, see README.
  if Rails.application.config.respond_to?(:spree_storefront)
    Rails.application.config.spree_storefront.body_end_partials << 'spree_all_in_one_accessibility/widget'
  end
end
