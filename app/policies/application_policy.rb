class ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    @user.roles.any?
  end

  def create?
    @user.role?("admin") || @user.role?("manager")
  end

  def update?
    @user.role?("admin") || @user.role?("manager")
  end

  def show?
    @user.roles.any?
  end

  def destroy?
    @user.role?("admin") || @user.role?("manager")
  end

  class Scope
    attr_reader :user, :scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager")
      if @user.role?("analyst")
        if scope.column_names.include?("draft")
          scope.where(draft: false)
        else
          scope.all
        end
      end
    end

    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end
end
