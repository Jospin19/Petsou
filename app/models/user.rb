class User < ApplicationRecord

  # On défini une sorte de Pte virtuelle pour gérer le type UploadFile
  attr_accessor :avatar_file

  # Permet de faciliter la gestion des passwd rails avc le chps password_diggest
  has_secure_password

  has_secure_token :confirmation_token
  has_secure_token :recover_password

  # Définition des Callback pour la gestion des avatars#
  # On défini le champ en bd à true
  before_save :avatar_before_upload
  # On effectue l'action suivante après la save du fichier
  after_save :avatar_after_upload
  after_destroy_commit :avatar_destroy



  validates :username,
            format: {with: /\A[a-zA-Z]{2,20}\z/, message: 'Ne doit contenir que des caractères alphanumériques ou des _'},
            uniqueness: {case_sensitive: false}

  validates :email,
            format:{with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/},
            uniqueness: {case_sensitive: false}

  # On défini une validation pour l'upload de fichier
  # POur cela le système nous demande de creer un validateur que nous avons crée et appelé file_validator et que nous avons mis dans /app/validators
  # D'ou le nom de la validation qui s'appelle file
  validates :avatar_file, file: {ext: [:jpg, :png]}

  def to_session
    {id: id}
  end

  def avatar_path
    File.join(
        Rails.public_path,
        'images',
        self.class.name.downcase.pluralize,
        id.to_s,
        'avatar.jpg'
    )
  end

  def avatar_url
    "/" + [
        'images',
        self.class.name.downcase.pluralize,
        id.to_s,
        'avatar.jpg'
    ].join("/")
  end


  def avatar_before_upload
    if avatar_file.respond_to? :path
      self .avatar = true
    end
  end

  private

  def avatar_after_upload
    # On va creer un file avec pour répertoire  : rep_public/images/nom_classe/id/avatar.jpg
    path = avatar_path

    #S'il s'agit bine d'un file
    if avatar_file.respond_to? :path
      #On récupère le chemin correspondant au répertoire
      dir = File.dirname(path)

      # On ne creer le répertoire == Chemin que s'il n'existe pas
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

      #On redéfinie la taille de l'image (minimalise) avec minimagik
      image = MiniMagick::Image.new(avatar_file.path) do |i|
        i.resize "150x150^"
        i.gravity "Center"
        i.crop "150x150+0+0"
      end

      #On redéfinie l'image en jpg
      image.format "jpg"
      # On écrit le fichier résultant de cette opération dans ce chemin
      image.write path
    end
  end

  def  avatar_destroy
    directory= File.direname(avatar_path)
    FileUtils.rm_r(directory) if Dir.exist?(directory)
  end


end
