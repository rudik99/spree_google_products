module Spree
  module Admin
    module GoogleShopping
      class IssuesController < Spree::Admin::BaseController
        
        def index
          @total_variants = Spree::Variant.count
          @issues_summary = []

          attributes_with_issues = Spree::GoogleVariantAttribute
                                     .where.not(google_issues: nil)
                                     .where.not(google_issues: "[]")
          grouped_issues = {}

          attributes_with_issues.each do |attr|
            next if attr.google_issues.blank?

            attr.google_issues.each do |issue|
              key = issue['description']
              if grouped_issues[key].nil?
                variant = Spree::Variant.find_by(id: attr.variant_id)
                product_id = variant&.product_id
                grouped_issues[key] = {
                  short_title: issue['description'],
                  long_title: issue['detail'], 
                  code: issue['code'],
                  affected_count: 0,
                  severity: issue['servability'],
                  example_product_id: product_id
                }
              end
              
              grouped_issues[key][:affected_count] += 1
            end
          end

          @issues_summary = grouped_issues.values.sort_by { |i| -i[:affected_count] }
        end
      end
    end
  end
end