module ApplicationHelper
  def back_button
    link_to '戻る', :back, class: 'bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-l ml-4'
  end

  def link_to_admin_top
    link_to 'トップ', admin_products_path, class: 'bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-l ml-4'
  end

  def delete_button(path)
    button_to '削除', path, method: :delete, data: { turbo_confirm: '本当に削除しますか？' },
    class: 'bg-transparent hover:bg-red-500 text-red-700 font-semibold hover:text-white py-2 px-4 border border-red-500 hover:border-transparent rounded ml-2'
  end

  def submit_button_class
    'w-1/2 bg-indigo-600 text-white py-2 px-4 rounded hover:bg-indigo-700 cursor-pointer'
  end

  def link_to_user_top
    link_to 'トップ', root_path, class: 'bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-l ml-4'
  end
end
