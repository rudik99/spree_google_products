module Spree
    module Admin
      module GoogleShoppingHelper
  
        def google_supported_countries_options
          [
            ['United States (US)', 'US'], ['India (IN)', 'IN'], ['United Kingdom (GB)', 'GB'],
            ['Canada (CA)', 'CA'], ['Australia (AU)', 'AU'], ['Germany (DE)', 'DE'],
            ['France (FR)', 'FR'], ['Italy (IT)', 'IT'], ['Spain (ES)', 'ES'],
            ['Netherlands (NL)', 'NL'], ['Brazil (BR)', 'BR'], ['Japan (JP)', 'JP'],
            ['Mexico (MX)', 'MX'], ['Austria (AT)', 'AT'], ['Belgium (BE)', 'BE'],
            ['Denmark (DK)', 'DK'], ['Finland (FI)', 'FI'], ['Greece (GR)', 'GR'],
            ['Hungary (HU)', 'HU'], ['Indonesia (ID)', 'ID'], ['Ireland (IE)', 'IE'],
            ['Israel (IL)', 'IL'], ['Malaysia (MY)', 'MY'], ['New Zealand (NZ)', 'NZ'],
            ['Norway (NO)', 'NO'], ['Philippines (PH)', 'PH'], ['Poland (PL)', 'PL'],
            ['Portugal (PT)', 'PT'], ['Romania (RO)', 'RO'], ['Russia (RU)', 'RU'],
            ['Saudi Arabia (SA)', 'SA'], ['Singapore (SG)', 'SG'], ['South Africa (ZA)', 'ZA'],
            ['South Korea (KR)', 'KR'], ['Sweden (SE)', 'SE'], ['Switzerland (CH)', 'CH'],
            ['Taiwan (TW)', 'TW'], ['Thailand (TH)', 'TH'], ['Turkey (TR)', 'TR'],
            ['Ukraine (UA)', 'UA'], ['United Arab Emirates (AE)', 'AE'], ['Vietnam (VN)', 'VN']
            # Add others if needed based on GMC docs
          ].sort
        end
  
        def google_supported_currencies_options
          [
            ['US Dollar (USD)', 'USD'], ['Indian Rupee (INR)', 'INR'], ['British Pound (GBP)', 'GBP'],
            ['Euro (EUR)', 'EUR'], ['Canadian Dollar (CAD)', 'CAD'], ['Australian Dollar (AUD)', 'AUD'],
            ['Japanese Yen (JPY)', 'JPY'], ['Brazilian Real (BRL)', 'BRL'], ['Mexican Peso (MXN)', 'MXN'],
            ['Swiss Franc (CHF)', 'CHF'], ['Hong Kong Dollar (HKD)', 'HKD'], ['New Zealand Dollar (NZD)', 'NZD'],
            ['Polish Zloty (PLN)', 'PLN'], ['Russian Ruble (RUB)', 'RUB'], ['Singapore Dollar (SGD)', 'SGD'],
            ['South African Rand (ZAR)', 'ZAR'], ['South Korean Won (KRW)', 'KRW'], ['Swedish Krona (SEK)', 'SEK'],
            ['Turkish Lira (TRY)', 'TRY'], ['Danish Krone (DKK)', 'DKK'], ['Norwegian Krone (NOK)', 'NOK']
          ].sort
        end
  
      end
    end
  end