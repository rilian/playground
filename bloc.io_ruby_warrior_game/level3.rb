# https://www.bloc.io/ruby-warrior

class Player
  def play_turn(warrior)
    if warrior.health < 20 && warrior.feel.empty?
      warrior.rest!
    else
      if warrior.feel.empty?
        warrior.walk!
      else
        warrior.attack!
      end
    end
  end
end
