class PageSerializer
  include FastVersionedSerializer

  attributes :title, :content, :menu_title, :order, :draft, :private

  set_type :pages
end
