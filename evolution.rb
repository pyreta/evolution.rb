class Being
	attr_accessor :days_without_eating, :strength, :speed,
		:smarts, :generation, :alive, :fitness

	def initialize (strength=100, speed=100, smarts=100, generation=1)
		@strength = strength
		@speed = speed
		@smarts = smarts
		@generation = generation
		@days_without_eating = 0
		@alive = true
		@possible_days_without_eating = 1
		@fitness = speed+strength+smarts
	end

	def change_trait(trait)
		change = trait/4.0.to_i
		rand(2)==1 ? trait+change : trait-change
	end

	def have_child
		child = self.class.new(strength=self.change_trait(@strength),
		speed=self.change_trait(@speed), smarts=self.change_trait(@smarts),
		generation = @generation+1)
	end

	def gets_meal(meal)
		if meal
			@days_without_eating = 0
		else
			@days_without_eating += 1
		end
		@alive = false if @days_without_eating>@possible_days_without_eating
	end

end

class World
	attr_accessor :population

	def initialize(generations = 1)
		@population = [Being.new]
		@generations = generations
	end

	def breed
		new_population = []
		@population.each do |being|
			2.times {new_population<<being.have_child}
			new_population<<being
		end
		@population = new_population
	end

	def kill_the_weak
		@population.keep_if {|being| being.alive}
	end

	def battle_for_meal(i)
		being1 = @population[i]
		being2 = @population[i+1]

		if being1.fitness > being2.fitness
			being1.gets_meal(true)
			being2.gets_meal(false)
		else
			being1.gets_meal(false)
			being2.gets_meal(true)
		end
	end

	def feed
		@population.shuffle!
		(0..@population.length).step(2).each do |i|
			break if i+1 >= @population.length
			# next if i+1 == @population.length
			self.battle_for_meal(i)
		end
		@population[-1].gets_meal(false) if @population.length % 2 != 0
		self.kill_the_weak

	end

	def evolve
		@generations.times do |i|
			p i
			self.breed
			3.times {self.feed}
		end
	end

	def strengths
		strong_beings = []
		smart_beings = []
		fast_beings = []
		@population.each do |being|
			traits = [being.strength, being.smarts, being.speed]
			case traits.index(traits.max)
			when 0
				strong_beings << being
			when 1
				smart_beings << being
			when 2
				fast_beings << being
			end
		end
		puts "Strong Beings: #{strong_beings.length}"
		puts "Smart Beings: #{smart_beings.length}"
		puts "Fast Beings: #{fast_beings.length}"
	end

end

w = World.new(generations=30)

w.evolve

puts "***population*****"
w.population.each_with_index do |being, i|
	puts "Being #{i+1}:"
	puts "Generation: #{being.generation}"
	puts "Strength: #{being.strength}"
	puts "Smarts: #{being.smarts}"
	puts "Speed: #{being.speed}"
	puts
end

w.strengths
