module LoginModule
  def admin_login(admin)
    visit new_admin_session_path

    fill_in 'admin_email', with: admin.email
    fill_in 'admin_password', with: admin.password
    within '.form-actions' do
      click_button 'ログイン'
    end
  end

  def user_login(user)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    within '.form-actions' do
      click_button 'ログイン'
    end
  end

  def vendor_login(vendor)
    visit new_vendor_session_path
    fill_in 'vendor_email', with: vendor.email
    fill_in 'vendor_password', with: vendor.password
    within '.form-actions' do
      click_button 'ログイン'
    end
    visit vendor_products_path
  end
end
