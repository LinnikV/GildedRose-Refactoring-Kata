require 'rspec'

require File.join(File.dirname(__FILE__) + '/..', 'gilded_rose')

describe Item do
  let(:item) { described_class.new("Conjured Mana Cake", 3, 6) }

  describe "#initialize" do
    it "creates an item with attributes" do
      expect(item.name).to eq("Conjured Mana Cake")
      expect(item.sell_in).to eq(3) 
      expect(item.quality).to eq(6)
    end
  end

  describe "#to_s" do
    it "returns correct string" do
      #expect(item.to_s).to eq("Conjured Mana Cake, 3, 6")
      expect(item.to_s).to be_an_instance_of(String)
    end
  end
end

describe GildedRose do
  ItemStruct = Struct.new(:name, :sell_in, :quality)

  let(:item) { ItemStruct.new('Test', 1, 1) }
  let(:item_aged) { ItemStruct.new('Aged Brie', 2, 0) }
  let(:item_sulfuras) { ItemStruct.new('Sulfuras, Hand of Ragnaros', 0, 80) }
  let(:item_backstage) { ItemStruct.new('Backstage passes to a TAFKAL80ETC concert', 15, 20) }
  let(:item_conjured) { ItemStruct.new('Conjured Mana Cake', 3, 6) }
  let(:items) { [item, item_aged, item_sulfuras, item_backstage, item_conjured] }
  let(:gilded_rose) { described_class.new(items) }

  describe "#initialize" do
    it "create array with items" do
      gilded_rose.update_quality()
      expect(items.size).to eq(5)
      expect(items.first.name).to eq("Test")
      expect(items.last.name).to eq("Conjured Mana Cake")
    end
  end

  describe '#item_updater' do
    it 'returns correct class for AgedItem' do
      expect(gilded_rose.send(:item_updater, item_aged)).to eq(AgedItem)
    end

    it 'returns correct class for SulfurasItem' do
      expect(gilded_rose.send(:item_updater, item_sulfuras)).to eq(SulfurasItem)
    end

    it 'returns correct class for BackstageItem' do
      expect(gilded_rose.send(:item_updater, item_backstage)).to eq(BackstageItem)
    end

    it 'returns correct class for ConjuredItem' do
      expect(gilded_rose.send(:item_updater, item_conjured)).to eq(ConjuredItem)
    end

    it 'returns correct class for StandartItem' do
      expect(gilded_rose.send(:item_updater, item)).to eq(StandartItem)
    end
  end

  describe '#update_quality' do
    it "does not change the name" do
      original_item = item.dup
      gilded_rose.update_quality()
      expect(items[0].name).to eq(original_item.name)
    end

    it "changes sell_in and quality" do
      expect { gilded_rose.update_quality() }.to change { items[0].quality }.by(-1).and change { items[0].sell_in }.by(-1)
    end

    it 'changes quality twice as fast after the sell_in date' do
      items[0].sell_in = 0
      items[0].quality = 5
      expect { gilded_rose.update_quality() }.to change { items[0].sell_in }.by(-1).and change { items[0].quality }.by(-2)
    end

    it "quality can't be negative" do
      items[0].sell_in = 0
      items[0].quality = 0
      expect { gilded_rose.update_quality() }.to change { items[0].sell_in }.by(-1).and change { items[0].quality }.by(0)
    end

    it "quality can't be more than 50" do
      items[0].quality = 55
      expect { gilded_rose.update_quality() }.to change { items[0].sell_in }.by(-1).and change { items[0].quality }.by(-5)
    end
  end

  describe '#update_quality for AgedItem class' do
    describe '.call' do
      it "quality increases" do
        expect { gilded_rose.update_quality() }.to change { items[1].sell_in }.by(-1).and change { items[1].quality }.by(+1)
      end

      it "quality increases twice as fast when sell_in < 0" do
        items[1].sell_in = 0
        expect { gilded_rose.update_quality() }.to change { items[1].sell_in }.by(-1).and change { items[1].quality }.by(+2)
      end
    end
  end

  describe "#update_quality for SulfurasItem class" do
    describe '.call' do
      it "quality does not change" do
        expect { gilded_rose.update_quality() }.not_to change { items[2].quality }
      end
    end
  end

  describe "#update_quality for BackstageItem class" do
    describe '.call' do
      it "quality increases by 2 when sell_in < 10" do
        items[3].sell_in = 10
        expect { gilded_rose.update_quality() }.to change { items[3].sell_in }.by(-1).and change { items[3].quality }.by(+2)
      end

      it "quality increases by 3 when sell_in < 5" do
        items[3].sell_in = 5
        expect { gilded_rose.update_quality() }.to change { items[3].sell_in }.by(-1).and change { items[3].quality }.by(+3)
      end

      it "quality drops to 0 after the concert date" do
        items[3].sell_in = 0
        expect { gilded_rose.update_quality() }.to change { items[3].sell_in }.by(-1).and change { items[3].quality }.to eq(0)
      end
      
      it "quality can't be more than 50" do
        items[3].sell_in = 4
        items[3].quality = 49
        expect { gilded_rose.update_quality() }.to change { items[3].sell_in }.by(-1).and change { items[3].quality }.to eq(50)
      end
    end
  end

  describe "#update_quality for ConjuredItem class" do
    describe '.call' do
      it "lose quality twice as fast when sell_in > 0" do
        expect { gilded_rose.update_quality() }.to change { items[4].sell_in }.by(-1).and change { items[4].quality }.by(-2)
      end

      it "lose quality four times faster if sell_in < 0" do
        items[4].sell_in = 0
        expect { gilded_rose.update_quality() }.to change { items[4].sell_in }.by(-1).and change { items[4].quality }.by(-4)
      end

      it "quality can't be negative" do
        items[4].sell_in = 0
        items[4].quality = 2
        expect { gilded_rose.update_quality() }.to change { items[4].sell_in }.by(-1).and change { items[4].quality }.to eq(0)
      end
    end
  end
end
