module IdvStepHelper
  def self.included(base)
    base.class_eval do
      include IdvHelper
      include JavascriptDriverHelper
      include SamlAuthHelper
      include DocAuthHelper
    end
  end

  def start_idv_from_sp(sp = :oidc)
    if sp.present?
      visit_idp_from_sp_with_ial2(sp)
    else
      visit root_path
    end
  end

  def complete_idv_steps_before_phone_step(user = user_with_2fa)
    sign_in_and_2fa_user(user)
    complete_all_doc_auth_steps
  end

  def complete_idv_steps_before_gpo_step(user = user_with_2fa)
    complete_idv_steps_before_phone_step(user)
    click_on t('idv.troubleshooting.options.verify_by_mail')
  end

  def complete_idv_steps_before_phone_otp_delivery_selection_step(user = user_with_2fa)
    complete_idv_steps_before_phone_step(user)
    fill_out_phone_form_ok('2342255432')
    click_idv_continue
  end

  def complete_idv_steps_before_phone_otp_verification_step(user = user_with_2fa)
    complete_idv_steps_before_phone_otp_delivery_selection_step(user)
    choose_idv_otp_delivery_method_sms
  end

  def complete_idv_steps_with_phone_before_review_step(user = user_with_2fa)
    complete_idv_steps_before_phone_step(user)
    fill_out_phone_form_ok(MfaContext.new(user).phone_configurations.first.phone)
    click_idv_continue
  end

  def complete_idv_steps_with_phone_before_confirmation_step(user = user_with_2fa)
    complete_idv_steps_with_phone_before_review_step(user)
    password = user.password || user_password
    fill_in 'Password', with: password
    click_idv_continue
  end

  alias complete_idv_steps_before_review_step complete_idv_steps_with_phone_before_review_step
  # rubocop:disable Layout/LineLength
  alias complete_idv_steps_before_confirmation_step complete_idv_steps_with_phone_before_confirmation_step
  # rubocop:enable Layout/LineLength

  def complete_idv_steps_with_gpo_before_review_step(user = user_with_2fa)
    complete_idv_steps_before_gpo_step(user)
    click_on t('idv.buttons.mail.send')
  end

  def complete_idv_steps_with_gpo_before_confirmation_step(user = user_with_2fa)
    complete_idv_steps_with_gpo_before_review_step(user)
    password = user.password || user_password
    fill_in 'Password', with: password
    click_continue
  end

  def complete_idv_steps_before_step(step, user = user_with_2fa)
    send("complete_idv_steps_before_#{step}_step", user)
  end
end
