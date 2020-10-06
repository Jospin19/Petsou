class UsersController < ApplicationController

  # On skip la vérification de l'user
  skip_before_action :only_signed_in, only: [:new, :create, :confirm]

  # On appliquera cette méthode uniquement pour les action new, create, et confirm
  # Avant d'appeler ces actions on vérifie s'il était déja connecté ou non
  before_action :only_signed_out, only: [:new, :create, :confirm]

  def new
    @user = User.new
  end

  def create
    # Liste des champs qu'on autorise. Ce sont les différents champs qui peuvent être entré par l'user
    user_params = params.require(:user).permit(:username, :email, :password, :password_confirmation)

    @user = User.new(user_params)

    # On pré rempli le token de sécurité du password
    @user.recover_password = nil

    if @user.valid?
      @user.save
      UserMailer.confirm(@user).deliver_now
      redirect_to new_user_path, success: 'Votre compte a bien été crée, vous devirez recevoir un email pour confirmer votre compte'

    else
      render 'new'
    end
  end

  # Méthode qui permettra de confimer un user par email
  def confirm
    @user = User.find(params[:id])
    #On verifie si le token de l'email est identique a celui stoké en bd

    if @user.confirmation_token == params[:token]
      #On signale que l'user est confirme confirmed: true, on supprime le token déja used confirmation_token: nil

      @user.update_attributes(confirmed: true, confirmation_token: nil )
      @user.save(validate: false)

      #Pour éviter d'avoir à reprendre cette opération pour tous les controllers(Users, et Sessions)
      # On va creer une méthode .to_session
=begin
      #On cree une session pour stoker l'id de l'user
      session[:auth] = {id: @user.id}
=end

      session[:auth] = @user.to_session


      redirect_to profil_path, success: 'Votre compte a bien ete confirme'
    else
      redirect_to new_user_path, danger: 'Ce token ne semble pas valide'
    end
  end


  # Action qui gère la redirection de l'user après sa vérification
  def edit
    # On récupère l'user courant
    # Cela se fait grace à la méthode current_user définie dans le application_controller en tant que helper
    @user = current_user
  end


  def update
    @user = current_user
    user_params = params.require(:user).permit(:username, :firstname, :lastname, :avatar_file, :email, )

    if @user.update(user_params)
      redirect_to profil_path, success: 'Votre compte a bien ete mis a jour'

    else
      render :edit
    end
  end
end
