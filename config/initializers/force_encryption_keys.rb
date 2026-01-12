if Rails.env.development? || Rails.env.test?
    env_file = Rails.root.join('.env')
    
    if File.exist?(env_file)
      File.foreach(env_file) do |line|
        next if line.strip.start_with?('#') || line.strip.empty?
        key, value = line.strip.split('=', 2)
        if key && value
          ENV[key] = value
        end
      end
    end
    
    if ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'].present?
      ActiveRecord::Encryption.configure(
        primary_key: ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'],
        deterministic_key: ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY'],
        key_derivation_salt: ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']
      )
      puts "🔐 Active Record Encryption Keys Loaded Successfully via Initializer."
    else
      puts "⚠️  WARNING: Active Record Encryption Keys are MISSING in .env"
    end
  end