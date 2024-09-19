module ApplicationHelper
  def back_button
    link_to '戻る', :back, class: 'bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-l ml-4'
  end

  def link_to_top
    link_to 'トップ', admin_products_path, class: 'bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-l ml-4'
  end
end
