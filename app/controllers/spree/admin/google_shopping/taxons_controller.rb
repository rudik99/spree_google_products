module Spree
    module Admin
      module GoogleShopping
        class TaxonsController < Spree::Admin::BaseController

          def drill_down
            parent_path = params[:parent_path]

            if parent_path.blank?

              categories = Spree::GoogleTaxon.pluck(:name).map { |n| n.split(' > ').first }.uniq.sort
            else

              prefix = "#{parent_path} > "
              
              categories = Spree::GoogleTaxon
                             .where("name LIKE ?", "#{prefix}%")
                             .pluck(:name)
                             .map { |n| n.sub(prefix, '').split(' > ').first }
                             .uniq
                             .sort
            end
  
            current_taxon_id = nil
            if parent_path.present?
              taxon = Spree::GoogleTaxon.find_by(name: parent_path)
              current_taxon_id = taxon&.google_id
            end
  
            render json: {
              categories: categories,
              current_id: current_taxon_id,
              is_leaf: categories.empty?
            }
          end
        end
      end
    end
  end