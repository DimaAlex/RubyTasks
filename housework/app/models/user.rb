class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :registerable, :confirmable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :tasks

  has_many :parent_relationships, :foreign_key => "parent_id", :class_name => "Relationship"
  has_many :children, :through => :parent_relationships

  has_many :child_relationships, :foreign_key => "child_id", :class_name => "Relationship"
  has_many :parents, :through => :child_relationships

  validates :name, :presence => true

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
    end
  end
end

