# All in One Accessibility® for Spree Commerce

This [free Spree Commerce accessibility extension](https://www.skynettechnologies.com/all-in-one-accessibility) adds an accessible experience to your [Spree Commerce](https://spreecommerce.org/) store for users with visual, auditory, motor, or cognitive disabilities. It supports assistive technologies, offers customizable updates, and enhances overall usability according to WCAG 2.1, 2.2, ADA, EAA, Section 508, France RGAA, California Unruh, European EAA EN 301 549, UK Equality Act, Spain UNE 139803:2012, Australian DDA, Israeli Standard 5568, Ontario AODA, Canada ACA, German BITV, Brazilian Inclusion Law (LBI 13.146/2015), JIS X 8341 (Japan), Italian Stanca Act, Indian RPwD Act, Switzerland DDA and other [accessibility standards](https://www.skynettechnologies.com/accessibility-standards). It is easy to install in Spree Commerce stores and enables quick, WCAG-aligned accessibility improvements and ongoing support for inclusive shopping experiences.

This [free accessibility widget](https://www.skynettechnologies.com/free-website-accessibility-widget) quickly adds essential accessibility features through a lightweight, easy to install solution that supports inclusive browsing and compliance efforts.

#### **What you get with the free Spree Commerce accessibility widget?**

- Auto-detect language
- Supports 190+ languages - ideal for global Spree Commerce stores
- Skip to Navigation / Content / Footer
- Content Adjustment Options
- Visual & Color Adjustments
- Widget customization including colors, size, icon, and position - right in the Spree Admin
- Reading mask
- Accessibility statement

Explore the **[free accessibility widget features guide](https://www.skynettechnologies.com/sites/default/files/Free-Accessibility-Widget-Features-Guide.pdf)**.

**This free Spree Commerce accessibility extension is a great fit for:**

- Ecommerce brands, marketplaces, agencies, developers, content teams, educational institutions, and public-facing organizations using Spree Commerce who want to improve WCAG accessibility, usability, and user experience quickly without complex development.

**Why select All in One Accessibility for Spree Commerce?**

- Supports alignment with global accessibility standards
- Improves usability for users with visual, cognitive, and motor impairments
- Works with the Spree Rails Storefront out of the box (including Turbo Drive) and with headless storefronts such as the Spree Next.js Storefront
- Supports 190+ languages and multiple stores for global accessibility reach
- Available at no cost for core accessibility features

## Version Matrix

| Spree Commerce | Extension version |
| --- | --- |
| 5.2 – 5.6 (Spree Admin) | 1.x |
| 6.0 (React dashboard) | Not supported yet |
| 4.x and older | Not supported |

### Requirements

- Spree Commerce 5.2 or newer (5.x) with the Spree Admin (`spree_admin`)
- A storefront:
  - the Spree Rails Storefront (`spree_storefront`) - the widget is added automatically, or
  - any headless storefront, such as the [Spree Next.js Storefront](https://spreecommerce.org/docs/developer/storefront/nextjs/quickstart) - add one script tag (see [Headless storefronts](#headless-storefronts-nextjs-and-others))
- The server running the Spree Admin must be able to reach `https://ada.skynettechnologies.us`. The settings page loads and saves the widget settings through this API.

## Installation

1. Add the extension to your Spree application:

   ```bash
   bundle add spree_all_in_one_accessibility
   ```

   With the Spree CLI (Docker):

   ```bash
   spree bundle add spree_all_in_one_accessibility
   ```

   To install the latest code from GitHub instead, add this line to your `Gemfile` and run `bundle install`:

   ```ruby
   gem 'spree_all_in_one_accessibility', github: 'skynettechnologies/spree-allinoneaccessibility'
   ```

2. Restart your server.

That's it. There are no migrations or generators to run.

## Configuration

1. In the Spree Admin, open **Settings → All in One Accessibility**.
2. Check the **Website domain**. It is the domain your customers visit, for example `shop.example.com`. The extension suggests your storefront URL, custom domains and store URL.
3. Customize the widget color, position, size, icon type, and icon size.
4. Select **Save changes**.

The first time the page opens for a domain, the domain is registered for the free plan automatically. Your widget settings are stored by All in One Accessibility for that domain and applied by the widget automatically. It may take a few seconds for changes to appear on your storefront. If you don't see them, clear your browser cache or check in a private browsing window.

| Setting | Description |
| --- | --- |
| Show the accessibility widget on the storefront | Adds the widget to every page of the Spree Rails Storefront. |
| Website domain | The domain the widget settings are saved for. Use the domain of your storefront. |
| Widget color | Any hex color, for example `#FF5733`. |
| Widget position | One of 8 predefined positions, or a precise position in pixels (0 - 250px from the chosen edges). |
| Widget size | Regular or oversize (oversize applies to the desktop view only). |
| Icon type | One of 29 icons. |
| Icon size | One of 5 predefined sizes, or an exact size in pixels (20 - 150px). |

### Storefront setup

#### Spree Rails Storefront

Nothing to do. The widget script is added at the end of `<body>` on every storefront page, including checkout.

The Rails Storefront uses [Turbo Drive](https://turbo.hotwired.dev/handbook/drive), which replaces the page body without reloading the page. The widget starts once per page load, so with the widget enabled:

- links load the next page normally, so the widget and the customer's accessibility preferences are always active, and
- form results (for example after signing in) keep the widget on screen.

#### Headless storefronts (Next.js and others)

Copy the script tag from **Settings → All in One Accessibility → Script for headless storefronts** and add it to the layout of your storefront, before the closing `</body>` tag. Make sure the **Website domain** setting is your storefront domain.

For the Spree Next.js Storefront, add it to the root layout (`src/app/layout.tsx`) with `next/script`, so it loads once and stays on every page:

```tsx
import Script from 'next/script';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Script
          id="aioa-adawidget"
          src="https://www.skynettechnologies.com/accessibility/js/all-in-one-accessibility-js-widget-minify.js?colorcode=&token=&position=bottom_right"
          strategy="afterInteractive"
        />
      </body>
    </html>
  );
}
```

#### Custom Rails layouts

If your storefront uses its own Rails layout, render the widget before the closing `</body>` tag:

```erb
<%= render 'spree_all_in_one_accessibility/widget' %>
```

### Multiple stores

Each store has its own settings. Switch to the store in the Spree Admin and open **Settings → All in One Accessibility** to configure its domain and widget.

### Permissions

The settings page is available to admin users who can update the store settings, the same as the other store settings pages.

### Advanced configuration

You can change the API connection timeouts in an initializer, for example `config/initializers/spree_all_in_one_accessibility.rb`:

```ruby
SpreeAllInOneAccessibility.configure do |config|
  config.open_timeout = 5  # seconds
  config.read_timeout = 10 # seconds
end
```

### CORS Policy Configuration

To avoid CORS policy issues, ensure the following URLs are allowed in your website. If your storefront sends a `Content-Security-Policy` header, add these domains to it as well.

| **Domain** | **Description** | **Usage** |
| --- | --- | --- |
| https://*.skynettechnologies.com | Skynet Technologies (Global Domain) | API access and resources |
| https://*.skynettechnologies.us | Skynet Technologies (US Domain) | API access and resources |
| https://*.googleapis.com | Google APIs | Services like Fonts, Translation |
| https://*.gstatic.com | Fonts APIs | Custom Fonts |
| https://vlibras.gov.br | VLibras - Brazilian Sign Language Service | Sign Language |

**Instructions**

1. Update your server's CORS (and Content-Security-Policy) configuration to include these URLs.
2. Ensure wildcard subdomains (\*) are supported where necessary.
3. Verify the application functionality by testing requests to these domains.
4. If issues persist, consult the documentation for CORS configuration guidance.

### Troubleshooting

| Problem | Solution |
| --- | --- |
| "The widget settings could not be loaded" on the settings page | The server cannot reach `https://ada.skynettechnologies.us`. Check your firewall or proxy, then reload the page. |
| "... is being registered for the free widget" | Registration of a new domain takes a few seconds. Reload the page. |
| The widget does not appear on the storefront | Check that **Show the accessibility widget on the storefront** is enabled. For headless storefronts, check that the script tag is in the layout. |
| The widget shows the default look instead of your settings | The **Website domain** must match the domain customers visit (without `https://` and without a port). |

## FAQs

**Does this free Spree Commerce accessibility extension support multilingual stores?**

Yes. It supports 190+ languages.

**Does it support multiple stores?**

Yes. Each store has its own domain and widget settings.

**Does it work with the Spree Next.js Storefront?**

Yes. Configure the widget in the Spree Admin and add the script tag to your storefront layout (see [Headless storefronts](#headless-storefronts-nextjs-and-others)).

**How can I upgrade from the free to the paid Spree Commerce accessibility widget?**

Upgrade to a paid subscription with **70 plus advanced features** and take your store's accessibility to the next level. Check out the steps for [upgrading from the free to the paid accessibility widget](https://www.skynettechnologies.com/blog/upgrade-from-all-in-one-accessibility-free-widget-to-premium-version).

**What additional features are available in the paid version?**

The paid version includes features like screen reader, voice navigation, talk & type, virtual keyboard, accessibility profiles tailored for different user groups with disabilities, Libras (Brazilian sign language), dictionary search, multi-language support (190+ languages), and many more. Pricing starts from $25 / month. Explore more information about the [accessibility widget](https://www.skynettechnologies.com/all-in-one-accessibility) and buy now.

**Will the widget slow down my store?**

No. The widget script is loaded with `defer`, so it never blocks page rendering.

**Supported Languages (190+ Languages)**

English (USA), English (UK), English (Australian), English (Canadian), English (South Africa), Español, Español (Mexicano), Deutsch, عربى, Português, Português (Brazil), 日本語, Français, Italiano, Polski, Pусский, 中文, 中文 (Traditional), עִברִית, Magyar, Slovenčina, Suomenkieli, Türkçe, Ελληνικά, Latinus, Български, Català, Čeština, Dansk, Nederlands, हिंदी, Bahasa Indonesia, 한국인, Lietuvių, Bahasa Melayu, Norsk, Română, Slovenščina, Svenska, แบบไทย, Українська, Việt Nam, বাঙালি, සිංහල, አማርኛ, Hmoob, မြန်မာ, Eesti keel, latviešu, Cрпски, Hrvatski, ქართული, ʻŌlelo Hawaiʻi, Cymraeg, Cebuano, Samoa, Kreyòl ayisyen, Føroyskt, Crnogorski, Azerbaijani, Euskara, Tagalog, Galego, Norsk Bokmål, فارسی, ਪੰਜਾਬੀ, shqiptare, Hայերեն, অসমীয়া, Aymara, Bamanankan, беларускі, bosanski, Corsu, ދިވެހި, Esperanto, Eʋegbe, Frisian, guarani, ગુજરાતી, Hausa, íslenskur, Igbo, Gaeilge, basa jawa, ಕನ್ನಡ, қазақ, ខ្មែរ, Kinyarwanda, Kurdî, Кыргызча, ພາສາລາວ, Lingala, Luganda, lëtzebuergesch, македонски, Malagasy, മലയാളം, Malti, Maori, मराठी, Монгол, नेपाली, Sea, ଓଡିଆ, Afaan Oromoo, پښتو, Runasimi, संस्कृत, Gàidhlig na h-Alba, Sesotho, Shona, سنڌي, Soomaali, basa Sunda, kiswahili, тоҷикӣ, தமிழ், Татар, తెలుగు, ትግሪኛ, Tsonga, Türkmenler, Ride, اردو, ئۇيغۇر, o'zbek, isiXhosa, יידיש, Yoruba, Zulu, भोजपुरी, डोगरी, कोंकणी, Kurdî, Krio, मैथिली, Meiteilon, Mizo tawng, Sepedi, Ilocano, دری

## Security & Privacy Notes

- All in One Accessibility follows several data and application security practices, including ISO 9001:2015 & ISO 27001:2013, GDPR, CCPA, COPPA, HIPAA, and SOC 2 Type II.
- Skynet Technologies USA LLC is an organizational member of IAAP and of W3C.
- The extension does not store personal data. Its settings (for example the website domain) are saved in the private metadata of each store, so no database migration is needed.
- When a domain is registered for the free plan, the website domain, the store name, and a `no-reply@<domain>` email address are sent to All in One Accessibility. Site owners are responsible for reviewing their own compliance requirements.

## Limitations

- Some advanced features require a commercial subscription.
- No accessibility overlay can guarantee full legal compliance on its own. See the [paid add-on services](#accessibility-paid-add-on-services) for manual audits and remediation.

## Documentation

- [All in One Accessibility](https://www.skynettechnologies.com/all-in-one-accessibility)
- [Free accessibility widget](https://www.skynettechnologies.com/free-website-accessibility-widget)
- [Accessibility widget features guide](https://www.skynettechnologies.com/sites/default/files/accessibility-widget-features-list.pdf)

**Submit a Support Request**

Please visit our [**support page**](https://www.skynettechnologies.com/report-accessibility-problem) and fill out the form. Our team will get back to you as soon as possible.

**Send Us an Email**

Alternatively, you can send an email to our support team: [**hello@skynettechnologies.com**](mailto:hello@skynettechnologies.com)

## Accessibility Paid Add-on Services

**[Spree Commerce manual accessibility audit](https://www.skynettechnologies.com/website-accessibility-audit)**

- Enhance inclusivity and user experience by evaluating your Spree Commerce store's accessibility with a [web accessibility consultant](https://www.skynettechnologies.com/web-accessibility-consultant).
- WCAG 2.0 / WCAG 2.1 / WCAG 2.2 Level AA conformance testing
- Automated, semi-automated testing
- Manual testing
- Simple before-after UI/UX recommendations on how to fix the issues
- Comprehensive audit report

**[Spree Commerce manual accessibility remediation](https://www.skynettechnologies.com/full-website-accessibility-remediation)**

Enhance your Spree Commerce store's accessibility and inclusivity with our manual accessibility remediation add-on. This service includes fixing accessibility issues and thorough remediation of the website manually. Our experts ensure accessibility with WCAG standards, improve user experience for those with disabilities, and provide a detailed report on the improvements made.

[**PDF/Document Accessibility Remediation**](https://www.skynettechnologies.com/pdf-accessibility-remediation)

The PDF / Document Remediation provides a list of inaccessible PDFs and remediated PDFs from where you can request PDF remediation service.

**[VPAT Report/Accessibility Conformance Report (ACR)](https://www.skynettechnologies.com/vpat-accessibility-conformance-report)**

The Voluntary Product Accessibility Template (VPAT), also known as an ACR (Accessibility Conformance Report), starts with an audit and provides current details for an accessible website, application, or any other digital assets.

**Spree Commerce Accessibility Widget Paid Add-ons**

[**White Label Accessibility**](https://www.skynettechnologies.com/all-in-one-accessibility/addons#accessibility-widget-add-ons)

Remove the Skynet Technologies logo as well as all of the footer links, popups, report a problem link and more for full white label control.

[**Instant live site translations for Spree Commerce stores**](https://www.skynettechnologies.com/all-in-one-accessibility/addons#accessibility-widget-add-ons)

Translate your Spree Commerce store into over 190 languages instantly to enhance accessibility for non-native speakers, individuals with language acquisition difficulties, and those with learning disabilities.

[**Modify Accessibility Menu for Spree Commerce stores**](https://www.skynettechnologies.com/all-in-one-accessibility/addons#accessibility-widget-add-ons)

Build and fine-tune the widget with the Modify Menu option. Reorder, remove and restructure the widget buttons to fit users' specific accessibility needs.

**Spree Commerce Accessibility Partnership Opportunities**

[**Accessibility agencies partnership**](https://www.skynettechnologies.com/agency-partners)

Partner with us as an agency to provide comprehensive Spree Commerce ADA, EAA, WCAG accessibility solutions to clients. Get access to exclusive resources, training, and support to implement and manage accessibility features effectively.

[**Accessibility affiliate partnership**](https://www.skynettechnologies.com/affiliate-partner)

Sign up for our affiliate program and earn commissions by promoting the accessibility extension. Share our widget with your network and help businesses improve their website accessibility while generating revenue.

For more details, explore [**accessibility partnership opportunities**](https://www.skynettechnologies.com/partner-program).

## Screenshots

![App Screenshot](https://www.skynettechnologies.com/sites/default/files/screenshot-1-free.jpg?v=3)

![App Screenshot](https://www.skynettechnologies.com/sites/default/files/screenshot-2-free.jpg?v=3)

![App Screenshot](https://www.skynettechnologies.com/sites/default/files/screenshot-3-free.jpg?v=3)

![App Screenshot](https://www.skynettechnologies.com/sites/default/files/screenshot-4-free.jpg?v=3)

## Development

Run the unit specs (no Spree application needed):

```bash
bundle exec rspec spec/lib
```

Run the full suite against a generated Spree test application:

```bash
bundle exec rake test_app
bundle exec rspec
```

Set `SPREE_VERSION` (for example `SPREE_VERSION="~> 5.4.0"`) to test another Spree version.

## Credits

This extension is developed and maintained by [website accessibility remediation company](https://www.skynettechnologies.com/) - Skynet Technologies USA LLC.

**Current Maintainers**

- [**Skynet Technologies USA LLC**](https://github.com/skynettechnologies)

## License

Distributed under the MIT License. See [LICENSE.md](LICENSE.md) for more information.
