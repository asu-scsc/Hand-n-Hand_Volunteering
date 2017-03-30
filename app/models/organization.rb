class Organization < ApplicationRecord
  has_many :locations
  before_save :downcase_email
  validates :name, presence: true, length: { maximum: 50}
  VALID_EMAIL_REGEX =/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255},
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6}, allow_nil: true

  def Organization.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def Organization.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = Organization.new_token
    update_attribute(:remember_digest, Organization.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end


  #add activated to organizations
    #def activate ???
  #update_attribute(:activated, true)
  #update_attribute(:activated_at, Time.zone.now)
  #end

  private

  def downcase_email
    self.email = email.downcase
  end

end
