require 'rails_helper'

describe OmniauthCallbacksController do
  let(:user) { create :user }

  shared_examples 'connect with' do |provider|
    it 'sets the notice flash' do
      subject
      expect(flash[:notice]).to eq "#{provider.capitalize} Connected successfully."
    end

    it 'redirects to the root path' do
      subject
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST #create' do
    subject { post :create }

    context 'when signs in with bitbucket account' do
      before do
        valid_bitbucket_login_setup uid: '123456', info: { email: 'test@xinminlabs.com' }
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:bitbucket]
      end

      context 'when the user signed in before' do
        before do
          create :identity, provider: :bitbucket, uid: '123456', user: user
        end

        it_behaves_like 'connect with', :bitbucket
        it { expect{ subject }.to change{ User.count }.by(0) }
        it { expect{ subject }.to change{ Identity.count }.by(0) }
      end

      context 'when the user sign in for the first time' do
        it_behaves_like 'connect with', :bitbucket

        it { expect{ subject }.to change{ User.count }.by(1) }
        it { expect{ subject }.to change{ Identity.count }.by(1) }
      end

      context 'when the user with same email already exists' do
        let!(:user) { create :user, email: 'test@xinminlabs.com' }

        it_behaves_like 'connect with', :bitbucket
        it { expect{ subject }.to change{ User.count }.by(0) }
        it { expect{ subject }.to change{ Identity.count }.by(1) }
      end
    end

    context 'when sign in with github account' do
      before do
        valid_github_login_setup uid: '123456', info: { email: 'test@xinminlabs.com' }
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
      end

      context 'when the user signed in before' do
        before do
          create :identity, provider: :github, uid: '123456'
        end

        it_behaves_like 'connect with', :github
        it { expect{ subject }.to change{ User.count }.by(0) }
        it { expect{ subject }.to change{ Identity.count }.by(0) }
      end

      context 'when the user signs in for the first time' do
        context 'when the github oauth response contains email' do
          it_behaves_like 'connect with', :github

          it { expect{ subject }.to change{ User.count }.by(1) }
          it { expect{ subject }.to change{ Identity.count }.by(1) }
        end

        context 'when the github oauth response does not contain email' do
          before do
            valid_github_login_setup
            request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
          end

          it 'renders the users/add_email template' do
            subject
            expect(response).to render_template('users/add_email')
          end
        end
      end

      context 'when the user with same email exists' do
        let!(:user) { create :user, email: 'test@xinminlabs.com' }

        it_behaves_like 'connect with', :github
        it { expect{ subject }.to change{ User.count }.by(0) }
        it { expect{ subject }.to change{ Identity.count }.by(1) }
      end
    end

    context 'when connect bitbucket account' do
      before do
        sign_in user

        valid_bitbucket_login_setup uid: '123456', info: { email: 'test@xinminlabs.com' }
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:bitbucket]
      end

      it_behaves_like 'connect with', :bitbucket
      it { expect{ subject }.to change{ User.count }.by(0) }
      it { expect{ subject }.to change{ Identity.count }.by(1) }

      context 'when the identity is already connected' do
        let!(:identity) { create Identity, uid: '123456', provider: :bitbucket, user: user }

        it { expect{ subject }.to change{ User.count }.by(0) }
        it { expect{ subject }.to change{ Identity.count }.by(0) }
      end
    end

    context 'when connects github account' do
      before do
        sign_in user

        valid_github_login_setup
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
      end

      it_behaves_like 'connect with', :github
      it { expect{ subject }.to change{ User.count }.by(0) }
      it { expect{ subject }.to change{ Identity.count }.by(1) }

      context 'when the identity is already connected' do
        let!(:identity) { create Identity, uid: '123456', provider: :github, user: user }

        it { expect{ subject }.to change{ User.count }.by(0) }
        it { expect{ subject }.to change{ Identity.count }.by(0) }
      end
    end
  end
end
