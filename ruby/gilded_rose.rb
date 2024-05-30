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
  def self.update_sell_in(item, index = 1)
    item.sell_in -= index
  end

  def self.update_quality(item, index = 1)
    index *= 2 if item.sell_in < 0
    item.quality += index
  end

  def self.check_limit(item)
    item.quality = 0 if item.quality < 0
    item.quality = 50 if item.quality > 50
  end
end

class AgedItem < ItemUpdater
  def self.call(item)
    update_sell_in(item)
    update_quality(item)
    check_limit(item)
  end
end

class SulfurasItem < ItemUpdater
  def self.call(item); end
end

class BackstageItem < ItemUpdater
  def self.call(item)
    update_sell_in(item)
    if item.sell_in < 0
      item.quality = 0
    else
      update_quality(item, item.sell_in < 5 ? 3 : (item.sell_in < 10 ? 2 : 1))
    end
    check_limit(item)
  end
end

class ConjuredItem < ItemUpdater
  def self.call(item)
    update_sell_in(item)
    update_quality(item, -2)
    check_limit(item)
  end
end

class StandartItem < ItemUpdater
  def self.call(item)
    update_sell_in(item)
    update_quality(item, -1)
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
