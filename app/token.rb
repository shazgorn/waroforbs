class Token
  # token -> user
  @@tokens = {}

  class << self
    ##
    # return User

    def get_user(token)
      @@tokens[token]
    end

    ##
    # []
    # token - string
    # user - User

    def set(token, user)
      @@tokens[token] = user
    end

    def drop_all
      @@tokens = {}
    end
  end
end
