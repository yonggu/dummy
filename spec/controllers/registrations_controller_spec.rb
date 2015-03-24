require 'rails_helper'

describe RegistrationsController do
  let!(:user) { create :user }
  let(:project) { create :project, owner: user }
  let(:invitation) { create :invitation, project: project, inviter: user, invitee: nil, email: 'member@xinminlabs.com' }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new user' do
        expect {
          post :create, user: { email: 'dummy@xinminlabs.com', password: '12345678', password_confirmation: '12345678' }
        }.to change{ User.count }.by(1)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new user' do
        expect {
          post :create, user: { email: nil, password: '12345678', password_confirmation: '12345678' }
        }.to change{ User.count }.by(0)
      end

      it 'renders the new template' do
        post :create, user: { email: nil, password: '12345678', password_confirmation: '12345678' }
        expect(response).to render_template('devise/registrations/new')
      end
    end

    context 'with invitation' do
      it 'creates a new user' do
        expect {
          post :create, user: { email: invitation.email, password: '12345678', password_confirmation: '12345678' }
        }.to change{ User.count }.by(1)
      end

      it 'sets the invitee in the invitation' do
        post :create, user: { email: invitation.email, password: '12345678', password_confirmation: '12345678' }
        expect(invitation.reload.invitee).not_to be_nil
      end
    end

    context 'with invitation and invitation token' do
      before do
        session[:invitation_token] = invitation.token
      end

      it 'sets invitation.accepted to be true' do
        post :create, user: { email: invitation.email, password: '12345678', password_confirmation: '12345678' }
        expect(invitation.reload.accepted).to be_truthy
      end

      it 'unset session invitation_token' do
        post :create, user: { email: invitation.email, password: '12345678', password_confirmation: '12345678' }
        expect(session[:invitation_token]).to be_nil
      end
    end

    context 'when signs in with github before' do
      before do
        create :identity, provider: :github, user: user

        post :create, user: { email: user.email, password: '12345678', password: '12345678' }
      end

      it { expect(response).to render_template('devise/registrations/new') }
    end

    context 'when signs in with bitbucket before' do
      before do
        create :identity, provider: :identity, user: user

        post :create, user: { email: user.email, password: '12345678', password: '12345678' }
      end

      it { expect(response).to render_template('devise/registrations/new') }
    end
  end
end
