module LoginModule
  def user_login(user)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    within '.form-actions' do
      click_button 'ログイン'
    end
  end
end
