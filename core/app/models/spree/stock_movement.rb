module Spree
  class StockMovement < Spree::Base
    belongs_to :stock_item, class_name: 'Spree::StockItem', inverse_of: :stock_movements
    belongs_to :originator, polymorphic: true

    after_create :update_stock_item_quantity

    validates :stock_item, presence: true
    validates :quantity, presence: true

    scope :recent, -> { order('created_at DESC') }

    def readonly?
      !new_record?
    end

    private

    def update_stock_item_quantity
      return unless self.stock_item.should_track_inventory?

      # FR: Update all backordered orders
      begin
        self.stock_item.variant.inventory_units.each {|iu| iu.order.update! }
      rescue 
        # just skip this for now
      end
      
      stock_item.adjust_count_on_hand quantity
    end

  end
end


