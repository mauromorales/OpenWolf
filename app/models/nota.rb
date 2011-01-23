class Nota < ActiveRecord::Base
  attr_accessor :dont_send_email
  
  belongs_to :proceso, :polymorphic => true
  belongs_to :usuario
  validates_presence_of :texto, :usuario_id
  
  after_create :notificar_creacion

  private

  def notificar_creacion
    Notificaciones.deliver_nueva_nota_seguimiento(self) unless (self.dont_send_email == true)
  end
end