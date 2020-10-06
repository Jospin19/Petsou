class SessionsController < ApplicationController

  #On Skip l'action demandant d'etre connecté only_signed
  skip_before_action :only_signed_in, only: [:new, :create]

  #On applique la méthode only_signed_out seulement pour les actions new et create
  # Car on ne peut appeler la déconnection que si on étatit au préalable connecté
  before_action :only_signed_out, only: [:new, :create]

  def new

  end

  def create
    # On a besoin de vérifier que l'user qui entré ses info a rempli des info correctes
    # On récupère ces infos à partir du hash(:user) crée au niveau du formulaire de création des sessions
    user_params = params.require(:user)
    @user = User.where(username: user_params[:username], confirmed: true ).or(User.where(email: user_params[:email], confirmed: true)).first

    if @user and @user.authenticate(user_params[:password])
      session[:auth] = @user.to_session
      redirect_to profil_path, success: 'Connexion reussie'
    else
      redirect_to new_session_path, danger: 'Identification incorrecte'
    end
  end

  def destroy
    session.destroy
    redirect_to new_session_path, success: 'Vous etes maintenant deconnecte'
  end
end
