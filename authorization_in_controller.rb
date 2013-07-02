

# ability.rb
ABILITY = {
  simple_user => {
    can => %w[name],
    cannot => %w[type],
  }
}

# user.rb
class User < ActiveRecord::Base
  # ...
end

# users_controller.rb
def update(user_id)
  load_user(user_id)

  # Now we have @user and this object is allowed for current_user to read

  ##
  # Here we do whatever we want and update user with new params
  # This may be service object or whatever
  #
  @user_updated = @user.dup.update_attributes(params[:user])

  # Now we have in @user_updated object with desired new attributes

  @user = apply_params_by_ability(@user_updated, :update)

  # If we are here - all is fine and current_user can do these changes
  @user.save!
end


private


def load_user(user_id)
  ##
  # Based on current_user properties, we build a set of SQL "where" matchers
  # to load only allowed user IDs
  #
  # id_by_ability(:read) returns them or updates "relation"
  #
  @user = Users.where(id: id_by_ability(:read))

  ##
  # Now when we know which IDs accessible at all, we perform formal find
  # which may return 404 or success
  #
  @user = @user.find(user_id)
end

##
# Just check if on the clone object all changed attributes are allowed to change
#
# Bonus: list if can/cannot change, to which values
#
def apply_params_by_ability(updated_object, ability)
  updated_object.changed_attributes.each do |attr|
    raise 401 if ABILITY[:simple_user].cannot.includes?(attr)
    raise 401 unless ABILITY[:simple_user].can.includes?(attr)
    @user[attr.to_sym] = updated_object[attr.to_sym]
  end
end
