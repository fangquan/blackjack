#! /usr/bin/ruby -w
require 'functions.rb'

class Player
	attr_accessor :hand,:money, :bet, :surrender, :index, :splitable, :parent;
	def initialize(hand, money, bet, surrender, index, splitable, parent)
		@hand  = hand;
		@money = money;
		@bet   = bet;
		@surrender  = surrender;
		@index     	= index;
		@splitable  = splitable;
		@parent     = parent;
	end
end

class Blackjack
	def initialize()
		@cards   = Array.new();
		@players = Array.new();
		@dealer  = Array.new();	  ## dealer is not a Player object, dealer is just
	end

	## setup how many players in this game
	def setup_new_players()
		begin 
			puts "How many players at the table ?(1 to 4 players)";
			@num_players = gets.to_i;
		end while @num_players < 1 or @num_players > 4
			@num_players.times do |i|
			p = Player.new(Array.new,1000,0,false,i,true,nil);
			@players.push p;
		end
	end

	## assign cards to players and dealer
	def setup_initial_cards()
		@cards  = Array.new;
		@dealer = Array.new;
		@num_decks = 2;
		$CARDS = [2,3,4,5,6,7,8,9,10,"J","K","Q","A"];
		(@num_decks*4).times {@cards += $CARDS};
		#puts "Shuffling cards ....";
		@cards = @cards.sort_by {rand};

		## assign cards to each player
		@players.each do |p|
			p.hand = [@cards.pop, @cards.pop];
			if p.hand[0] != p.hand[1]
				p.splitable = false;
			end
			#p.hand = [2,2];
			#print p.hand
		end


		## assign cards to the dealer
		@dealer = [@cards.pop, @cards.pop];
	end

	## One round game's bets
	def get_player_bets()
		print "################ BET ##################\n";
		@players.each do |p|
			done = false;
			while(!done)
				print "Player #{p.index}, current $#{p.money}.\n";
				print "please enter your bet ($1 --- $#{p.money}) : ";
				bet = gets.to_i
				if (bet > 0 and bet <= p.money)
					p.bet = bet;
					done = true;
				end
			end
		end
		print "#######################################\n\n\n";
	end

	## print one player's state
	def print_player_state(p)
			puts "PLAYER #{p.index} ";
			puts "\t money:  \t #{p.money}"
			puts "\t bet:  \t\t #{p.bet}"
			puts "\t hand: \t\t #{p.hand.join(',')}"
			puts "\t value:  \t #{value p.hand}"
    end

	## print the dealer's state
	def print_dealer_state()
		puts "############### DEALER ################";
    	puts "#{@dealer[0]}, X "
		puts "############### DEALER ################\n\n\n";
    end

    # Loop for each players, and ask for their actions
	def get_player_actions()
	    ## While loop for each player, taking their actions
	    puts "############  PLAYERS ACTION     ###########"
		@players.each do |pl|
	 		playing = true
	 		while (playing)
				print_player_state(pl);

				# Check if player has a blackjack at the very beginning
				if blackjack(pl.hand)
					puts "Player #{pl.index} has a blackjack!"
					playing = false
					next
	        	end

				print "Player #{pl.index}, action (hit, split, surrender, double, stand): ";
				action = gets.chomp

				while ( pl.splitable == false ) and (action == "split")
					puts "Player is not splitable, there are 3 possibilities: "
					puts "(1) Your initial hand (#{pl.hand[0]},#{pl.hand[1]}) cards don't match."
					puts "(2) You already splitted."
					puts "(3) You are a 'child player' splitted from your parent."
					print "Player #{pl.index}, action (hit, split, surrender, double, stand): ";
					action = gets.chomp
				end

				action = action.strip;	## remove the leading and trailing white spaces
				case action
					when "hit"
						## Player takes a new card.
						## Player still has the chance to take more cards.
						new_card = @cards.pop 
						pl.hand << new_card

					when "split"
						## Player is splitable.
						## Player's first two cards have the same value and seperate them to two hands.
						## Add the child hand to the @players array. 
						## Parent hand and child hand are not splitable any more.
						## After the judgement round, the child hand will be removed from the array
						pl_copy = Player.new(Array.new, pl.money, pl.bet, false, pl.index.to_s+"_copy", false, pl);
						pl_copy.hand  = [pl.hand.pop, @cards.pop];
						pl.hand = [pl.hand.pop, @cards.pop];
						pl.splitable = false;
						idx = @players.index(pl);
						@players.insert(idx+1,pl_copy);
						puts "############### SPLITTING ################";

					when "surrender"
						## Player surrenders, he will be penalized half of his original bets
						pl.bet = pl.bet / 2;
						pl.surrender = true;
						playing = false;

		        	when "double"
		        		## Double wager, the player takes a single card and done.
		        		new_card = @cards.pop
		        		pl.hand << new_card
		        		if pl.money > 2 * pl.bet;
		        			pl.bet = 2 * pl.bet;
		        		else
		        			pl.bet = pl.money;
		        		end
		        		if value(pl.hand) < 21
			        		print_player_state(pl);
						end
		        		playing = false
		        	when "stand"
		        		## The Players doesn't take any more cards.
		        		playing = false
		        	else
		        		puts "no such action, try again..."
				end

				if value(pl.hand) > 21 # Lost :(
					print_player_state(pl);
					playing = false
				elsif value(pl.hand) == 21 # 21, but not blackjack, so maybe we draw with the dealer, we check later
					print_player_state(pl);
					playing = false
				end
			end
		end
		puts "############  PLAYERS ACTION END ###########\n\n\n"
	end

	## after players finish taking actions, the dealer takes his actions, based on hitting 16 and staying on 17
	def get_dealer_actions()
		puts "############  DEALER ACTION     ############"
		d = value(@dealer)
	    # Dealer hits on 16 and stays on 17
		while d < 17
			@dealer << @cards.pop
			d = value(@dealer)
		end
		puts "Dealer, HAND #{@dealer.join(',')}, Value #{value @dealer}"
		puts "############  DEALER ACTION END ############\n\n\n"
	end

	## After palyers and dealer took their actions
	## We compare the hand of the dealer with every players hands (except the guy who surrenders), and act accordingly
	def judgement_round()
		d = value(@dealer)
		puts "############   JUDGEMENT ROUND  ############"
		# Iterate over all players who are still in the game,
		# as in they haven't lost in the initial round doing 'hits'

		@players.each do |p|
			if p.surrender == true;
				puts "PLAYER #{p.index}, HAND: #{p.hand.join(',')}, Value #{value p.hand}, SURRENDER"
				debit_player(p, p.bet);
				next;
			end

			v = value(p.hand);
			if blackjack(p.hand)
				puts "Player #{p.index} has blackjack, WIN !"
				if  p.parent != nil 
					credit_player(p.parent, p.bet, blackjack = true);
				else
					credit_player(p, p.bet, blackjack=true)
				end
			elsif  v > 21 and d <= 21
				puts "PLAYER #{p.index}, HAND: #{p.hand.join(',')}, Value #{value p.hand}, LOSE"
				if  p.parent != nil 
					debit_player(p.parent, p.bet);
				else
					debit_player(p, p.bet);
				end
			elsif  v > 21 and d > 21
				puts "PLAYER #{p.index}, HAND: #{p.hand.join(',')}, Value #{value p.hand}, DRAW"
			elsif v <= 21 and d > 21
				puts "PLAYER #{p.index}, HAND: #{p.hand.join(',')}, Value #{value p.hand}, WIN "
				if p.parent != nil
					credit_player(p.parent, p.bet)
				else
					credit_player(p, p.bet);
				end
			elsif v < d && d <= 21 # Dealer Wins
				puts "PLAYER #{p.index}, HAND: #{p.hand.join(',')}, Value #{value p.hand}, LOSE"
				if  p.parent != nil 
					debit_player(p.parent, p.bet);
				else
					debit_player(p, p.bet);
				end
			elsif v > d && v <= 21 # Player Wins
				puts "PLAYER #{p.index}, HAND: #{p.hand.join(',')}, Value #{value p.hand}, WIN "
				if p.parent != nil
					credit_player(p.parent, p.bet)
				else
					credit_player(p, p.bet);
				end
			elsif v == d
				puts "PLAYER #{p.index}, HAND: #{p.hand.join(',')}, Value #{value p.hand}, DRAW"
			end
		end
		puts "############ JUDGEMENT ROUND END ###########\n\n\n"
	end

	## After the split copy took his action, it will be removed from the player list
	## The split copy is a fake player.
	def remove_split_copy()
		@players.delete_if { |p| p.index.to_s =~ /copy/};
	end

	## After the game, remove the players who went bankruptcy
	def remove_bankrupt_player()
		@players.reject! { |p| p.money <= 0};
		if @players.length == 0
			puts "Everyone runs bankruptcy, game over";
			exit();
		end
	end

	## After the game, print all the remaining players
	def player_status()
		puts "############ PLAYERS IN THE GAME ###########"
		puts "#{@players.length} players still in the game"
		@players.each do |p|
			puts "PLAYER #{p.index}, $#{p.money}";
		end
		puts "############ PLAYERS IN THE GAME ###########\n\n\n"
	end
end

class Run
	def initialize()
		puts "Welcome to the Blackjack game";
	end

	def Run()
		b = Blackjack.new;
		b.setup_new_players();
		### main loop of the whole thing
		begin
			b.setup_initial_cards();
			b.get_player_bets();
			b.print_dealer_state();
			b.get_player_actions();
			b.get_dealer_actions();
			b.judgement_round();
			b.remove_bankrupt_player();
			b.remove_split_copy();
			b.player_status();
			print "Continue? (yes|no)";
			action = gets.chomp;
		end	while action == "yes"
		puts "Byebye";
	end
end

game = Run.new;
game.Run();