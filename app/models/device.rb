class Device < ApplicationRecord
  belongs_to :user
  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :events # we are retaining events after delete
  # rubocop:enable Rails/HasManyOrHasOneDependent
  attr_accessor :nice_name
  validates :user_id, presence: true
  validates :cookie_uuid, presence: true
  validates :last_used_at, presence: true
  validates :last_ip, presence: true

  def decorate
    DeviceDecorator.new(self)
  end

  def device_name
    DeviceTracking::DeviceName.call(UserAgentParser::Parser.new, self)
  end
end
