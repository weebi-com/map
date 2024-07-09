# config/initializers/country_select.rb

# Return a string to customize the text in the <option> tag, `value` attribute will remain unchanged
CountrySelect::FORMATS[:with_alpha2] = lambda do |country|
  "#{country.iso_short_name} (#{country.alpha2})"
end
