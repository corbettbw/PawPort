# config/initializers/geocoder.rb

Geocoder.configure(
  timeout: 3,
  units: :mi,

  lookup: Rails.env.production? ? :google : :test,
  api_key: Rails.env.production? ? ENV["GOOGLE_MAPS_API_KEY"] : nil,
  use_https: Rails.env.production?
)
