module SpreeGoogleProducts
  module Generators
    class UninstallGenerator < Rails::Generators::Base
      
      def drop_tables
        return unless yes?("WARNING: This will destroy all Google Shopping data (Credentials, Product Settings, Taxonomies). Are you sure? [y/N]")

        tables = %w[spree_google_credentials spree_google_product_attributes spree_google_variant_attributes spree_google_taxons]

        tables.each do |table|
          if ActiveRecord::Base.connection.table_exists?(table)
            ActiveRecord::Base.connection.drop_table(table, force: :cascade)
            puts "🔥 Dropped table: #{table}"
          else
            puts "   Table #{table} does not exist, skipping."
          end
        end
      end

      def remove_migrations
        migration_files = Dir.glob("db/migrate/*add_spree_google_shopping_tables.spree_google_products.rb")
        migration_files += Dir.glob("db/migrate/*spree_google_products.rb")

        if migration_files.any?
          migration_files.uniq.each do |file|
            version = File.basename(file).split('_').first
            if version.match?(/^\d+$/)
              ActiveRecord::Base.connection.execute("DELETE FROM schema_migrations WHERE version = '#{version}'")
              puts "🧹 Removed version #{version} from schema_migrations."
            end

            remove_file file
          end
        else
          puts "⚠️  No specific migration files found to remove."
        end
      end

      def remove_initializer
        remove_file "config/initializers/force_encryption_keys.rb"
      end

      def clean_env_reminder
        puts "\n"
        puts "⚠️  IMPORTANT: We did not remove the Encryption Keys from your .env file."
        puts "   If you are not using them for other plugins, please manually remove:"
        puts "   - ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"
        puts "   - ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"
        puts "   - ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"
        puts "\n"
        puts "✅ Spree Google Products has been uninstalled."
      end
    end
  end
end