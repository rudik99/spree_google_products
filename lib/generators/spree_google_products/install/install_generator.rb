require 'securerandom'

module SpreeGoogleProducts
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      class_option :auto_run_migrations, type: :boolean, default: false

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_google_products'
      end

      def create_initializer
        initializer_content = <<~RUBY
          if Rails.env.development? || Rails.env.test?
            env_file = Rails.root.join('.env')
            
            if File.exist?(env_file)
              File.foreach(env_file) do |line|
                next if line.strip.start_with?('#') || line.strip.empty?
                key, value = line.strip.split('=', 2)
                ENV[key] = value if key && value
              end
            end
          
            if ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'].present?
              ActiveRecord::Encryption.configure(
                primary_key: ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'],
                deterministic_key: ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY'],
                key_derivation_salt: ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']
              )
            end
          end
        RUBY

        create_file "config/initializers/force_encryption_keys.rb", initializer_content
      end

      def setup_encryption_keys
        return unless Rails.env.development? || Rails.env.test?
        env_file = File.join(Rails.root, '.env')
        create_file '.env' unless File.exist?(env_file)
        current_content = File.read(env_file)
        keys_to_add = []
        
        {
          "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY" => SecureRandom.alphanumeric(32),
          "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY" => SecureRandom.alphanumeric(32),
          "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT" => SecureRandom.alphanumeric(32)
        }.each do |key_name, value|
          unless current_content.include?(key_name)
            keys_to_add << "#{key_name}=#{value}"
          end
        end

        if keys_to_add.any?
          append_to_file '.env', "\n# --- Added by Spree Google Shopping Installer ---\n#{keys_to_add.join("\n")}\n"
          puts "🔑 Added missing Active Record Encryption keys to .env"
        else
          puts "✅ Active Record Encryption keys already present."
        end
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))
        if run_migrations
          run 'bundle exec rails db:migrate'
        else
          puts 'Skipping rails db:migrate, don\'t forget to run it!'
        end
      end

      def run_seeds
        run_seeds = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to download and seed Google Taxonomies now? (Recommended) [Y/n]'))
        if run_seeds
          run 'bundle exec rake spree_google_shopping:seed_taxons'
        else
          puts 'Skipping seed. You can run it later with: bundle exec rake spree_google_shopping:seed_taxons'
        end
      end
    end
  end
end