module SpreeGoogleProducts
    class Ability
      include CanCan::Ability
  
      def initialize(user)
        return unless user.present? && user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
        can :manage, Spree::GoogleCredential
      end
    end
  end