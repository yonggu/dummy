class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    if user
      can [:create, :setup_scm, :import], Project
      can :read, Project, id: user.project_ids
      can :update, Project, id: user.project_ids
      can :destroy, Project do |project|
        user.owner_of?(project)
      end

      can :manage, HipchatConfig, project: { id: user.project_ids }
      can :create, HipchatConfig

      can :manage, SlackConfig, project: { id: user.project_ids }
      can :create, SlackConfig

      can :manage, Build, project: { id: user.project_ids }
      can :create, Build

      can :manage, User, id: user.id

      can :read, Membership, project: { id: user.project_ids }
      can :manage, Membership do |membership|
        user.owner_of?(membership.project)
      end
      cannot :destroy, Membership, role: "owner"
    else
      can :create, User
    end
  end
end
