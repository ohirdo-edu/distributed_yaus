class LinkEntry < ApplicationRecord
  before_create :set_short_id

  validates :external_url, presence: true
  
private
  def set_short_id
    self.short_id = Digest::SHA1.hexdigest(SecureRandom.uuid)[...10]
  end
end
