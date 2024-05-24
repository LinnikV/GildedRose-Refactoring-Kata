class GildedRose
  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each do |item|
      item_updater(item).call(item)
    end
  end

  private

  def item_updater(item)
    case item.name
    when /Aged/
      AgedItem
    when /Sulfuras/
      SulfurasItem
    when /Backstage passes/
      BackstageItem
    when /Conjured/
      ConjuredItem
    else
      StandartItem
    end
  end
end

class ItemUpdater 
  def self.sell_in_down(item, index = 1)
    item.sell_in -= index
  end

  def self.quality_up(item, index = 1)
    index *= 2 if item.sell_in < 0
    item.quality += index
  end

  def self.quality_down(item, index = 1)
    index *= 2 if item.sell_in < 0
    item.quality -= index
  end

  def self.check_limit(item)
    item.quality = 0 if item.quality < 0
    item.quality = 50 if item.quality > 50
  end
end

class AgedItem < ItemUpdater
  def self.call(item)
    sell_in_down(item)
    quality_up(item)
    check_limit(item)
  end
end

class SulfurasItem < ItemUpdater
  def self.call(item); end
end

class BackstageItem < ItemUpdater
  def self.call(item)
    sell_in_down(item)
    quality_up(item) if item.sell_in > 11
    quality_up(item, 2) if item.sell_in < 11
    quality_up(item, 3) if item.sell_in < 6
    item.quality = 0 if item.sell_in < 0
    check_limit(item)
  end
end

class ConjuredItem < ItemUpdater
  def self.call(item)
    sell_in_down(item)
    quality_down(item, 2)
    check_limit(item)
  end
end

class StandartItem < ItemUpdater
  def self.call(item)
    sell_in_down(item, index = 1)
    quality_down(item, index = 1)
    check_limit(item)
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
