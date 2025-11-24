# config/initializers/geocoder.rb
Geocoder.configure do |config|
  config.timeout = 3          # seconds
  config.units   = :mi        # or :km

  if Rails.env.production?
    # Production: real Google calls
    config.lookup = :google
    config.api_key = ENV["GOOGLE_MAPS_API_KEY"]
    config.use_https = true
  else
    # Dev & test: NO real HTTP calls by default
    # :test lookup always returns a fixed fake result and never hits an API.
    config.lookup = :test
  end
end
