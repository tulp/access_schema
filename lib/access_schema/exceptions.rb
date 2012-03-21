module AccessSchema

  class Error < RuntimeError; end

  class DefinitionError < Error; end
  class CheckError < Error; end
  class AccessError < CheckError; end


  class NotAlowedError < AccessError; end

  class NoRoleError < CheckError; end
  class NoResourceError < CheckError; end
  class NoPrivilegeError < CheckError; end

end
