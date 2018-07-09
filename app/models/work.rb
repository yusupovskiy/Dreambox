class Work < ApplicationRecord
  # belongs_to :client

  # enum position_work: {administrator: 'administrator', 
  #   moderator: 'moderator', accountant: 'accountant', 
  #   responsible: 'responsible', director: 'director'}

  enum position_work: {administrator: 'administrator', director: 'director'}

  validates :position_work, :people_id, presence: true
end
