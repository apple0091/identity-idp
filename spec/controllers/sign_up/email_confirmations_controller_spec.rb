require 'rails_helper'

describe SignUp::EmailConfirmationsController do
  describe '#create' do
    before do
      stub_analytics
    end

    it 'tracks nil email confirmation token' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: nil }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks blank email confirmation token' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: '' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks confirmation token as a single-quoted empty string' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: "''" }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks confirmation token as a double-quoted empty string' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: '""' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks already confirmed token' do
      user = create(:user, confirmation_token: 'foo')

      analytics_hash = {
        success: false,
        errors: { email: [t('errors.messages.already_confirmed')] },
        user_id: user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: 'foo' }
    end

    it 'tracks expired token' do
      user = create(:user, :unconfirmed)
      UpdateUser.new(
        user: user,
        attributes: { confirmation_token: 'foo', confirmation_sent_at: Time.zone.now - 2.days },
      ).call

      analytics_hash = {
        success: false,
        errors: { confirmation_token: [t('errors.messages.expired')] },
        error_details: { confirmation_token: [:expired] },
        user_id: user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: 'foo' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_period_expired')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks blank confirmation_sent_at as expired token' do
      user = create(:user, :unconfirmed)
      UpdateUser.new(
        user: user,
        attributes: { confirmation_token: 'foo', confirmation_sent_at: nil },
      ).call

      analytics_hash = {
        success: false,
        errors: { confirmation_token: [t('errors.messages.expired')] },
        error_details: { confirmation_token: [:expired] },
        user_id: user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: 'foo' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_period_expired')
      expect(response).to redirect_to sign_up_email_resend_path
    end
  end

  describe 'Valid email confirmation tokens' do
    it 'tracks a valid email confirmation token event' do
      user = create(:user, :unconfirmed, confirmation_token: 'foo')

      stub_analytics

      analytics_hash = {
        success: true,
        errors: {},
        user_id: user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with(Analytics::USER_REGISTRATION_EMAIL_CONFIRMATION, analytics_hash)

      get :create, params: { confirmation_token: 'foo' }
    end
  end

  describe 'Two users simultaneously confirm email with race condition' do
    it 'does not throw a 500 error' do
      allow(subject).to receive(:process_successful_confirmation).
        and_raise(ActiveRecord::RecordNotUnique)

      get :create, params: { confirmation_token: 'foo' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end
  end
end
