class OrbError < RuntimeError
end

class WrongToken < OrbError
end

class BuildingAlreadyInProgress < OrbError
end
