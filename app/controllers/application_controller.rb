class ApplicationController < ActionController::Base

  # Protéger l'application rails contre la faille CSRF
  protect_from_forgery with: :exception

  # On interdit à l'user d'exécuter une action s''il n'est pas connecté
  before_action :only_signed_in

  add_flash_types :success, :danger

  #On définie un helper(Méthode qui sera exécutée ans le reste de l'application)
  helper_method :current_user, :user_signed_in?

  private

  def only_signed_in
    if !user_signed_in?
      redirect_to new_user_path, danger: "Vous n'avez pas le droit d'accéder à cette page!"
    end
  end

  # Retourne l'utilisateur actuellement connecté
  def current_user
    return nil if !session[:auth] || !session[:auth]['id']
    return @_user if @_user
    #Find_by contrairement a Find renvie la valeur nil et non un execption lorsqu'il ne trouve pas le résultat
    @_user =  User.find_by_id(session[:auth]['id'])
  end

  def user_signed_in?
    !current_user.nil?
  end

  def only_signed_out
    redirect_to profil_path if user_signed_in?
  end

end
