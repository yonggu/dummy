require 'rails_helper'

describe Ability do
  let(:user) { create :user }
  let(:owner) { create :user }
  let(:member) { create :user }
  let(:project) { create :github_project }
  let!(:owner_membership) { create :membership, project: project, user: owner, role: :owner }
  let!(:member_membership) { create :membership, project: project, user: member, role: :member }
  let(:hipchat_config) { create :hipchat_config, project: project }
  let(:slack_config) { create :slack_config, project: project }
  let(:build) { create :build, project: project }

  context 'when the user is not the member of the project' do
    let(:ability) { Ability.new user }

    it { expect(ability).to be_can :create, Project }
    it { expect(ability).to be_can :setup_scm, Project }
    it { expect(ability).to be_can :import, Project }
    it { expect(ability).not_to be_can :read, project }
    it { expect(ability).not_to be_can :update, project }
    it { expect(ability).not_to be_can :destroy, project }

    it { expect(ability).to be_can :create, HipchatConfig }
    it { expect(ability).not_to be_can :manage, hipchat_config }

    it { expect(ability).to be_can :create, SlackConfig }
    it { expect(ability).not_to be_can :manage, slack_config }

    it { expect(ability).to be_can :create, Build }
    it { expect(ability).not_to be_can :manage, build }

    it { expect(ability).to be_can :manage, user }
    it { expect(ability).not_to be_can :manage, owner }
    it { expect(ability).not_to be_can :manage, member }
    it { expect(ability).not_to be_can :read, owner_membership }
    it { expect(ability).not_to be_can :read, member_membership }
  end

  context 'when the user is the member but not the owner of the project' do
    let(:ability) { Ability.new member }

    it { expect(ability).to be_can :create, Project }
    it { expect(ability).to be_can :setup_scm, Project }
    it { expect(ability).to be_can :import, Project }
    it { expect(ability).to be_can :read, project }
    it { expect(ability).to be_can :update, project }
    it { expect(ability).not_to be_can :destroy, project }

    it { expect(ability).to be_can :create, HipchatConfig }
    it { expect(ability).to be_can :manage, hipchat_config }

    it { expect(ability).to be_can :create, SlackConfig }
    it { expect(ability).to be_can :manage, slack_config }

    it { expect(ability).to be_can :create, Build }
    it { expect(ability).to be_can :manage, build }

    it { expect(ability).not_to be_can :manage, user }
    it { expect(ability).not_to be_can :manage, owner }
    it { expect(ability).to be_can :manage, member }

    it { expect(ability).to be_can :read, owner_membership }
    it { expect(ability).to be_can :read, member_membership }
    it { expect(ability).not_to be_can :manage, owner_membership }
    it { expect(ability).not_to be_can :manage, member_membership }
  end

  context 'when the user the owner of the project' do
    let!(:ability) { Ability.new owner }

    it { expect(ability).to be_can :create, Project }
    it { expect(ability).to be_can :setup_scm, Project }
    it { expect(ability).to be_can :import, Project }
    it { expect(ability).to be_can :read, project }
    it { expect(ability).to be_can :update, project }
    it { expect(ability).to be_can :destroy, project }

    it { expect(ability).to be_can :create, HipchatConfig }
    it { expect(ability).to be_can :manage, hipchat_config }

    it { expect(ability).to be_can :create, SlackConfig }
    it { expect(ability).to be_can :manage, slack_config }

    it { expect(ability).to be_can :create, Build }
    it { expect(ability).to be_can :manage, build }

    it { expect(ability).not_to be_can :manage, user }
    it { expect(ability).to be_can :manage, owner }
    it { expect(ability).not_to be_can :manage, member }

    it { expect(ability).to be_can :read, owner_membership }
    it { expect(ability).to be_can :read, member_membership }
    it { expect(ability).to be_can :manage, owner_membership }
    it { expect(ability).to be_can :manage, member_membership }
    it { expect(ability).not_to be_can :destroy, owner_membership }
  end
end
