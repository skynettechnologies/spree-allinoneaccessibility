# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-10

### Added

- Automatic injection of the All in One Accessibility widget at the end of `<body>` on every Spree Rails Storefront page.
- Turbo Drive compatibility for the Rails Storefront, so the widget stays visible after navigating between pages.
- **Settings → All in One Accessibility** page in the Spree Admin:
  - show or hide the widget on the storefront, per store,
  - website domain (with suggestions from the storefront URL, custom domains and the store URL),
  - ready-to-copy script tag for headless storefronts (Next.js and others),
  - widget color, predefined or precise (pixel) position, widget size, 29 icon types, predefined or custom icon size,
  - automatic free plan registration of new domains,
  - free plan upgrade banner.
- Access limited to admin users who can update the store settings.
