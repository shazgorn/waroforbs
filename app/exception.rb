class OrbError < RuntimeError
end

class WrongToken < OrbError
end

class UnableToComplyBuildingInProgress < OrbError
end

class NotEnoughResources < OrbError
end

class MaxBuildingLevelReached < OrbError
end
