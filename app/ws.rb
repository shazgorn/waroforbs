##
# TODO: move to game.rb
#
# Set defender`s data from +res+ in +users+
# +res+ is a result of the +attack+ execution
# +users+ hash of attacking and defending users

def set_def_data users, res
  if res.has_key?(:d_user) && res[:d_user]
    log_msg = "damage taken ca_dmg: %d, damage dealt dmg: %d" % [res[:d_data][:ca_dmg], res[:d_data][:dmg]]
    if res[:d_data][:dead]
      log_msg += '. Your hero has been killed.'
    end
    log_entry = Log.push res[:d_user], log_msg, :attack
    if user_online?(res[:d_user])
      users[res[:d_user].id] = res[:d_data]
      users[res[:d_user].id][:log] = log_entry
    end
  end
end

def save_and_exit
  logger.info "Terminating..."
  @game.dump
  logger.info "Good bye!"
  exit
end
