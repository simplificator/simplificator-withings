class Withings::MeasurementGroup
  ATTRIBUTION_DEVICE = 0
  ATTRIBUTION_DEVICE_AMBIGUOUS = 1
  ATTRIBUTION_DEVICE_MANUALLY = 2
  ATTRIBUTION_DEVICE_MANUALLY_DURING_CREATION = 4

  CATEGORY_MEASURE = 1
  CATEGORY_TARGET = 2

  TYPE_WEIGHT = 1                     # kg
  TYPE_SIZE = 4                       # m
  TYPE_FAT_FREE_MASS_WEIGHT = 5       # kg
  TYPE_FAT_RATIO = 6                  # % (unitless)
  TYPE_FAT_MASS_WEIGHT = 8            # kg
  TYPE_DIASTOLIC_BLOOD_PRESSURE = 9   # mmHg (min, lower)
  TYPE_SYSTOLIC_BLOOD_PRESSURE = 10   # mmHg (max, upper)
  TYPE_HEART_PULSE = 11               # bpm
  # new, updated Measure Types
  TYPE_TEMPERATURE = 12               # °C
  TYPE_SP02 = 54                      # % (unitless)
  TYPE_BODY_TEMPERATURE = 71          # °C
  TYPE_SKIN_TEMPERATURE = 74          # °C
  TYPE_MUSCLE_MASS = 76               # kg (?)
  TYPE_HYDRATION = 77                 # ?
  TYPE_BONE_MASS = 88                 # kg (?)
  TYPE_PULSE_WAVE_VELOCITY = 91       # ms (?)

  attr_reader :group_id, :attribution, :taken_at, :category
  attr_reader :weight, :size, :fat, :ratio, :fat_free, :diastolic_blood_pressure, :systolic_blood_pressure, :heart_pulse
  def initialize(params)
    params = params.stringify_keys
    @group_id = params['grpid']
    @attribution = params['attrib']
    @taken_at = Time.at(params['date'])
    @category = params['category']
    # init @values
    @values = Hash.new
    params['measures'].each do |measure|
      value = (measure['value'] * 10 ** measure['unit']).to_f
      case measure['type']
      when TYPE_WEIGHT then @values['weight'] = value
      when TYPE_SIZE then @values['size'] = value
      when TYPE_FAT_MASS_WEIGHT then @values['fat'] = value
      when TYPE_FAT_RATIO then @values['ratio'] = value
      when TYPE_FAT_FREE_MASS_WEIGHT then @values['fat_free'] = value
      when TYPE_DIASTOLIC_BLOOD_PRESSURE then @values['diastolic_blood_pressure'] = value
      when TYPE_SYSTOLIC_BLOOD_PRESSURE then @values['systolic_blood_pressure'] = value
      when TYPE_HEART_PULSE then @values['heart_pulse'] = value
      # new, updated Measure Types
      when TYPE_TEMPERATURE then @values['temperature'] = value
      when TYPE_SP02 then @values['sp02'] = value
      when TYPE_BODY_TEMPERATURE then @values['body_temperature'] = value
      when TYPE_SKIN_TEMPERATURE then @values['skin_temperature'] = value
      when TYPE_MUSCLE_MASS then @values['muscle_mass'] = value
      when TYPE_HYDRATION then @values['hydration'] = value
      when TYPE_BONE_MASS then @values['bone_mass'] = value
      when TYPE_PULSE_WAVE_VELOCITY then @values['pulse_wave_velocity'] = value
      end
    end
  end

  def created_at
    $stderr.puts "created_at has been deprecated in favour of taken_at. Please updated your code."
  end

  def measure?
    self.category == CATEGORY_MEASURE
  end

  def target?
    self.category == CATEGORY_TARGET
  end

  # @return [String]
  def to_s
    '[' + @values.map{|key, value| "#{key}: #{value}"}.join(', ') + ', ' + "ID: #{self.group_id} (taken at: #{self.taken_at.strftime("%d.%m.%Y %H:%M:%S")})]"
  end

  # @return [String]
  def inspect
    self.to_s
  end
  
  # If the method is missing then look at @values Array wether the name is present
  # @param [String] m Name of the called method which is not present itself
  def method_missing(m, *args, &block)
    @values.dig(m)
  end
end
