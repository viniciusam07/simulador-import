class PublicLink < ApplicationRecord
  belongs_to :simulation
  has_many :public_link_accesses, dependent: :destroy

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :expiration_in_the_future

  before_validation :generate_token, on: :create

  def expired?
    expires_at < Date.current
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def expiration_in_the_future
    return if expires_at.blank?

    if expires_at < Date.current
      errors.add(:expires_at, "deve ser uma data futura.")
    end
  end
end
