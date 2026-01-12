require 'google/apis/content_v2_1'

module Spree
  module GoogleShopping
    class StatusService
      def initialize(credential)
        @credential = credential
        @merchant_id = credential.merchant_center_id
        @service = Google::Apis::ContentV2_1::ShoppingContentService.new
        @service.authorization = Spree::GoogleTokenService.new(credential).token
      end

      def fetch_counts
        stats = Rails.cache.fetch("google_shopping_stats_#{@merchant_id}", expires_in: 15.minutes) do
          Rails.cache.write("google_shopping_last_updated_#{@merchant_id}", Time.current)
          calculate_fresh_counts
        end
        
        last_updated = Rails.cache.read("google_shopping_last_updated_#{@merchant_id}")
        
        stats.merge(last_updated: last_updated)
      rescue => e
        Rails.logger.error "GOOGLE STATS ERROR: #{e.message}"
        { approved: 0, limited: 0, pending: 0, disapproved: 0, error: true, last_updated: nil }
      end

      def sync_statuses_to_db
        page_token = nil
        puts "🔄 Starting Google Status Sync (Variant Level)..."
        affected_product_ids = Set.new
        loop do
          begin
            response = @service.list_productstatuses(@merchant_id, page_token: page_token)
          rescue => e
            puts "❌ API Error: #{e.message}"
            break
          end
          
          if response.resources
            response.resources.each do |resource|
              # 1. Extract SKU
              sku = resource.product_id.split(':').last
              
              # 2. Get Status
              dest = resource.destination_statuses&.find { |s| s.destination == 'Shopping' } || resource.destination_statuses&.first
              next unless dest
              
              status = dest.status 

              # 3. Find Variant
              variant = Spree::Variant.find_by(sku: sku)
              next unless variant

              # Mark Parent Product for update later
              affected_product_ids.add(variant.product_id)

              # 4. Update Variant Attribute Table
              v_attr = variant.google_variant_attribute || variant.build_google_variant_attribute
              
              # Capture Issues
              if resource.item_level_issues.present?
                issues_list = resource.item_level_issues.map do |issue|
                  {
                    code: issue.code,
                    description: issue.description,
                    detail: issue.detail,
                    resolution: issue.resolution,
                    servability: issue.servability
                  }
                end
                v_attr.google_issues = issues_list
              else
                v_attr.google_issues = [] 
              end

              v_attr.google_status = status
              v_attr.save
              print "."
            end
          end

          page_token = response.next_page_token
          break if page_token.nil?
        end
        
        puts "\n🔄 Updating Parent Product Aggregates..."
        update_parent_products(affected_product_ids)
        
        puts "✅ Sync Complete!"
      end

      private

      def update_parent_products(product_ids)
        Spree::Product.where(id: product_ids).find_each do |product|
          all_variants = [product.master] + product.variants
          statuses = all_variants.map { |v| v.google_variant_attribute&.google_status }.compact

          aggregate_status = if statuses.include?('disapproved')
                               'disapproved'
                             elsif statuses.include?('pending')
                               'pending'
                             elsif statuses.include?('approved')
                               'approved'
                             else
                               'not_synced'
                             end
          
          g_attr = product.google_product_attribute || product.build_google_product_attribute
          g_attr.google_status = aggregate_status
          g_attr.save
        end
      end

      def calculate_fresh_counts
        stats = { approved: 0, limited: 0, disapproved: 0, pending: 0 }
        
        page_token = nil
        loop do
          response = @service.list_productstatuses(@merchant_id, page_token: page_token)
          
          if response.resources
            response.resources.each do |resource|
              dest = resource.destination_statuses&.find { |s| s.destination == 'Shopping' } || resource.destination_statuses&.first
              next unless dest

              case dest.status
              when 'disapproved'
                stats[:disapproved] += 1
              when 'pending'
                stats[:pending] += 1
              when 'approved'
                if resource.item_level_issues.present?
                  stats[:limited] += 1
                else
                  stats[:approved] += 1
                end
              end
            end
          end

          page_token = response.next_page_token
          break if page_token.nil?
        end

        stats
      end
    end
  end
end