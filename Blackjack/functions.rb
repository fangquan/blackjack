## Calcualte the value of a player's hand
def value(hand)
	# Sorting hack to get aces at the very end so we count them last
	@Ace 	 = Array.new;
	@total   = 0;
	hand.each do |i|
		if [2,3,4,5,6,7,8,9,10].include? i
			@total = @total + i;
		elsif ["J","Q","K"].include? i
			@total = @total + 10;
		else
			@Ace.push(i);
		end
	end

	@Ace.each do |i|
		if (@total + 11) > 21
			@total = @total + 1;
		else
			@total = @total + 11;
		end
	end
	return @total;
end

## return true if this is a blackjack
def blackjack(hand)
	value(hand) == 21 && hand.length == 2
end

## increment money to the player
## credit 3:2, for a blackjack case
def credit_player(p, bet, blackjack = false)
	if blackjack
		p.money += (3 * bet)/2; 
	else
		p.money += bet
	end
end

## Player loses his bet if he lost
## A fake player decrement his parent's money
def debit_player(p, bet)
	p.money -= bet
end