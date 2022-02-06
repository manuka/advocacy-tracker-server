class BookmarkPolicy < ApplicationPolicy
  def create?
    @record.user == @user
  end

  def edit?
    @record.user == @user
  end

  def update?
    @record.user == @user
  end

  def destroy?
    @record.user == @user
  end

  def permitted_attributes
    [:user_id, :title, :view]
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: @user.id)
    end
  end
end
