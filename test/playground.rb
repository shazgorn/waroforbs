require 'celluloid/current'
require 'pp'

class MyActor
  include Celluloid

  def initialize name
    puts "init MyActor with name #{name}"
    @name = name
  end

  def name
    @name
  end

  def crash
    raise RuntimeError, "Oops"
  end
end

class MyContainer < Celluloid::Supervision::Container
end

Celluloid::Actor[:first] = MyActor.new 'first'
Celluloid::Actor[:second] = MyActor.new 'second'

MyContainer.supervise({as: 'actor_1', type: MyActor, args: [{name: 'supertest'}]})

cont = MyContainer.run!
# p MyContainer.blocks

#Celluloid::Actor[:my_actor].links.inspect

#p cont.registry.names

#p cont.actors

#cont.restart_actor(cont[:my_actor], 'just')

cont['actor_1'.to_sym].async.crash
puts 'Waiting for crash'
sleep 1
puts 'Exiting'
sleep 1
