class LinkEntry < ApplicationRecord
  before_create :set_short_id

  validates :external_url, presence: true

  def self.get_external_url(short_id)
    Rails.cache.fetch("short_id/#{short_id}") do
      self.find_by!(short_id: short_id).external_url
    end
  end
  
private
  def set_short_id
    self.short_id = Digest::SHA1.hexdigest(SecureRandom.uuid)[...10]
  end
end
