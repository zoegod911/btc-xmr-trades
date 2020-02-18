module ApplicationHelper
  def build_options_for_trade_items
    opts = []

    @top_level = Category.where(ancestry: nil)
    @top_level.each do |c|
      opts << ['─────────────────────', nil]
      opts << [c.title, nil]
      opts << ['─────────────────────', nil]

      immediate_children = TradeItem.where(category_id: c.id).order(title: :asc)
      immediate_children.each do |immediate_child|
        opts << ["─#{immediate_child.title}", immediate_child.id]
      end
    end

    opts << ['──────────', nil]
  end

end
