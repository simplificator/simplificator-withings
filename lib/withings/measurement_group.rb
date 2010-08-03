class Withings::MeasurementGroup
  ATTRIBUTION_SCALE = 0
  ATTRIBUTION_SCALE_AMBIGUOUS = 1
  ATTRIBUTION_SCALE_MANUALLY = 2
  ATTRIBUTION_SCALE_MANUALLY_DURING_CREATION = 4

  CATEGORY_MEASURE = 1
  CATEGORY_TARGET = 2

  TYPE_WEIGHT = 1
  TYPE_SIZE = 4
  TYPE_FAT_FREE_MASS_WEIGHT = 5
  TYPE_FAT_RATIO = 6
  TYPE_FAT_MASS_WEIGHT = 8

  attr_reader :group_id, :attribution, :created_at, :category
  attr_reader :weight, :height, :fat, :ratio, :fat_free
  def initialize(params)
    params = params.keys_as_string
    @group_id = params['grpid']
    @attribution = params['attrib']
    @created_at = Time.at(params['date'])
    @category = params['category']
    params['measures'].each do |measure|
      value = (measure['value'] * 10 ** measure['unit']).to_f
      case measure['type']
      when TYPE_WEIGHT then @weight = value
      when TYPE_SIZE then @height = value
      when TYPE_FAT_MASS_WEIGHT then @fat = value
      when TYPE_FAT_RATIO then @ratio = value
      when TYPE_FAT_FREE_MASS_WEIGHT then @fat_free = value
      else raise "Unknown #{measure.inspect}"
      end
    end
  end

  def measure?
    self.category == CATEGORY_MEASURE
  end

  def target?
    self.category == CATEGORY_TARGET
  end

  def bmi
    if self.height && self.weight
      self.weight / (self.height ** 2)
    end
  end

  def to_s
    "[ Weight: #{self.weight}, Fat: #{self.fat}, Height: #{self.height}, BMI: #{self.bmi}, Ratio: #{self.fat_ratio}, Free: #{self.fat_free_weight}, ID: #{self.group_id}]"
  end

  def inspect
    self.to_s
  end



end
