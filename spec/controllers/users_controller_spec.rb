require 'rails_helper'

describe UsersController do
  let(:user) { create :user }

  describe "POST #create" do
    it "create user successfully" do
      expect {
        post :create, user: {"email"=>"9741588@qq.com", "identities_attributes"=>{"0"=>{"uid"=>"335502", "provider"=>"github", "access_token"=>"9fc05629d1ed284a41fcaee9760456fe67e369d6"}}}
      }.to change{ User.count }.by(1)
    end
  end

  describe "GET #show" do
    before do
      sign_in user
      get :show, id: user.id
    end

    it { is_expected.to render_template('show')}
  end
end
