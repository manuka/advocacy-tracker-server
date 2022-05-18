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
      return scope.all if user.role?("admin")
      return resolve_for_manager if user.role?("manager")
      return resolve_for_analyst if user.role?("analyst")
    end

    def resolve_for_analyst
      analyst_scope = scope.all
      analyst_scope = analyst_scope.where(draft: false) if scope.column_names.include?("draft")
      analyst_scope = analyst_scope.where(is_archive: false) if scope.column_names.include?("is_archive")
      analyst_scope = analyst_scope.where(private: false) if scope.column_names.include?("private")

      analyst_scope
    end

    def resolve_for_manager
      manager_scope = scope.all
      if scope.column_names.include?("private")
        manager_scope = manager_scope
          .where(private: false)
          .or(manager_scope.where(created_by_id: user.id))
      end
      manager_scope = manager_scope.where(is_archive: false) if scope.column_names.include?("is_archive")
      manager_scope
    end

    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end
end
