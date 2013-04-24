Quan Fang
April 15, 2013
quan_fang@brown.edu


Usage: 
	$ ruby blackjack.rb
	

Data Structures:
	Class Player
		### members variables
		@hand  ## cards in player's hand
		@money ## money the player has
		@bet   ## money the player bets in this game
		@surrender  ## boolean, true if the player surrenders, false otherwise
		@index      ## index of the players' array
		@splitable  ## boolean, true if the player can be splitted, false if not. 
			    ## A player can't be splitted in three cases: 
			    ## (1) Initial hand two hands can't match each other; 
			    ## (2) The player has been splitted already.	
			    ## (3) The player is splitted from it's parent 	
		@parent     ## The player when the current player is splitted (derived) from. For a first-level player, parent is nil.


	Class Blackjack
		### member variables
		@cards   = Array.new();	  ## @cards used in this game. We use 2 decks of cards	
		@players = Array.new();	  ## array of players in this game	   
		@dealer  = Array.new();	  ## @dealer is not a Player object, @dealer is just an array of cards

		### member functions
		## setup how many players in this game
		def setup_new_players()
	
		## assign cards to players and dealer
		def setup_initial_cards()
	
		## Ask players what's their bets
		def get_player_bets()
	
		## print the dealer's state
		def print_dealer_state()
	
		# Loop for each players, and ask for their actions
		def get_player_actions()
	
		## after players finish taking actions, the dealer takes his actions, based on hitting 16 and staying on 17
		def get_dealer_actions()
	
		## After palyers and dealer took their actions
		## We compare the hand of the dealer with every players hands (except the guy who surrenders), and act accordingly	
		def judgement_round()
	
		## After the split copy took his action, it will be removed from the player list
		## The split copy is a fake player.
		def remove_split_copy()
	
		## After the game, remove the players who went bankruptcy
		def remove_bankrupt_player()	

	Class Run
		## Setup the whole blackjack game
		Run()
	

File Dependency
	requires 'functions.rb'
	## Calcualte the value of a player's hand
	def value(hand)		

	## return true if this is a blackjack
	def blackjack(hand)	

	## increment money to the player
	## credit 3:2, for a blackjack case
	def credit_player(p, bet, blackjack = false)

	## Player loses his bet if he lost
	## A fake player decrement his parent's money
	def debit_player(p, bet)

	These three methods are not logically necessary belonging to any class. Thus, I put them seperately.


