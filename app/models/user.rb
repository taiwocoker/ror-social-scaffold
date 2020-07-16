class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { minimum: 3, maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :confirmed_friendships, -> { where status: 'accepted' }, class_name: "Friendship", foreign_key: 'sender_id'
  has_many :friends, through: :confirmed_friendships, source: :receiver
  has_many :pending_friendships, -> { where status: nil }, class_name: "Friendship", foreign_key: "sender_id"
  has_many :pending_friends, through: :pending_friendships, source: :receiver
  has_many :inverted_friendships, -> { where status: nil }, class_name: "Friendship", foreign_key: "receiver_id"
  has_many :friend_requests, through: :inverted_friendships, source: :sender
  
  
  
  def self.all_friends(user_id)
    User.where('id != ?', user_id)
  end

  def friends
    sent_requests.map { |friendship| friendship.sender_id if friendship.status == 'accepted' }.compact
  end
end
