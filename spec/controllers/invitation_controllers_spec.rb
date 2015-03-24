require 'rails_helper'

describe InvitationsController do
  let(:user) { create :user, email: 'admin@xinminlabs.com' }
  let(:project) { create :project, owner: user, name: 'Owner/Project' }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it {
        expect { post :create, project_id: project.id, invitation: { email: 'recipient@xinminlabs.com.com'}  }.to change{ Invitation.count }.by(1)
      }

      it 'redirects to memberships page' do
        post :create, project_id: project.id, invitation: { email: 'recipient@xinminlabs.com' }
        expect(response).to redirect_to edit_project_path(project, anchor: 'memberships')
      end

      it 'sets flash with notice' do
        post :create, project_id: project.id, invitation: { email: 'recipient@xinminlabs.com' }
        expect(flash[:notice]).to eq 'You invited recipient@xinminlabs.com to Owner/Project.'
      end
    end

    context 'with invalid attributes' do
      it {
        expect { post :create, project_id: project.id, invitation: { email: ''}  }.to change{ Invitation.count }.by(0)
      }

      it 'redirects to memberships page' do
        post :create, project_id: project.id, invitation: { email: '' }
        expect(response).to redirect_to edit_project_path(project, anchor: 'memberships')
      end

      it 'sets flash with alert' do
        post :create, project_id: project.id, invitation: { email: '' }
        expect(flash[:alert]).to eq ["Email can't be blank"]
      end
    end

    context 'with email have been invited' do
      before do
        create :invitation, inviter: user, project: project, email: 'recipient@xinminlabs.com'
      end

      it {
        expect { post :create, project_id: project.id, invitation: { email: 'recipient@xinminlabs.com' } }.to change{ Invitation.count }.by(0)
      }

      it 'redirects to memberships page' do
        post :create, project_id: project.id, invitation: { email: 'recipient@xinminlabs.com' }
        expect(response).to redirect_to edit_project_path(project, anchor: 'memberships')
      end

      it 'sets flash with alert' do
        post :create, project_id: project.id, invitation: { email: 'recipient@xinminlabs.com' }
        expect(flash[:alert]).to eq ["Email has been invited."]
      end
    end
  end
end
