# https://www.bloc.io/ruby-warrior

class Player
  def go_or_attack(warrior)
    if warrior.feel.captive?
      warrior.rescue!
    else
      if warrior.feel.empty?
        warrior.walk!
      else
        warrior.attack!
      end
    end
  end

  def play_turn(warrior)
    @health = warrior.health if @health.nil?

    if @health > warrior.health
      go_or_attack(warrior)
    else
      if warrior.health < 20 && warrior.feel.empty?
        warrior.rest!
      else
        go_or_attack(warrior)
      end
    end

    @health = warrior.health
  end
end
