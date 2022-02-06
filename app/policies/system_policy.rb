class SystemPolicy < ApplicationPolicy
  def create?
    false
  end

  def destroy?
    false
  end

  def update?
    false
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
