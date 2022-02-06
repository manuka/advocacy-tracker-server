class PagePolicy < ApplicationPolicy
  def edit?
    false
  end

  def permitted_attributes
    [:title, :content, :menu_title, :draft, :order]
  end
end
