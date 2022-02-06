class RolePolicy < SystemPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def permitted_attributes
    []
  end
end
