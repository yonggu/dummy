require 'rails_helper'

describe MembershipsController do
  let(:owner) { create :user }
  let(:member) { create :user, name: 'Member' }
  let(:project) { create :project }
  let!(:owner_membership) { create :membership, user: owner, project: project, role: :owner }
  let!(:member_membership) { create :membership, user: member, project: project, role: :member }

  describe "DELETE #destroy" do
    before do
      sign_in owner
    end

    context 'when it is going to remove the member' do
      it {
        expect {
          delete :destroy, id: member_membership.id, project_id: project.id
        }.to change{ project.memberships.reload.count }.by(-1)
      }

      it 'sets the alert notice' do
        delete :destroy, id: member_membership.id, project_id: project.id
        expect(flash[:notice]).to eq "You have removed Member from this project."
      end

      it 'redirects to the members page' do
        delete :destroy, id: member_membership.id, project_id: project.id
        expect(response).to redirect_to edit_project_path(project, anchor: 'memberships')
      end
    end

    context 'when it is going to remove the owner' do
      it {
        expect {
          delete :destroy, id: owner_membership.id, project_id: project.id
        }.to change{ project.memberships.count }.by(0)
      }

      it 'sets the notice flash' do
        delete :destroy, id: owner_membership.id, project_id: project.id
        expect(flash[:alert]).to eq 'You can not remove the owner.'
      end

      it 'redirects to the members page' do
        delete :destroy, id: owner_membership.id, project_id: project.id
        expect(response).to redirect_to edit_project_path(project, anchor: 'memberships')
      end
    end
  end
end
