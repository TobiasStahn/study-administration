# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.5'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(custom.css)
Rails.application.config.assets.precompile += %w(courseOverview.css)
Rails.application.config.assets.precompile += %w(doneEventsOverview.css )
Rails.application.config.assets.precompile += %w(app/assets/*)
Rails.application.config.assets.precompile += %w(app/assets/javascripts/profiles.coffee)
