#!/usr/bin/perl

use lib "$ENV{HOME}/lib";
use revmod;

foreach $arg (@ARGV) {
	if ($arg eq "-h" || $arg eq "--help")
	{
		open FILE, "help_reversi.txt" or open FILE, "$ENV{HOME}/lib/help_reversi.txt" or die "Nie mogę znaleźć pliku z pomocą";
		while(<FILE>)
		{
			print $_;
		}
		exit;
		close FILE;
	}
}

print "Witaj w grze Reversi\n";

while (1)
{
	revmod::getNewBoard;
	revmod::resetBoard;
	revmod::choseTile;
	$turn = revmod::whoGoesFirst;
	revmod::clearScreen;
	print "Pierwszy zaczyna $turn \n";
	while (1)
	{
		if ($turn eq 'gracz')
		{
			#ruch gracza
			revmod::drawBoard;
			revmod::showScore($revmod::playerTile, $revmod::computerTile);
			revmod::getPlayerMove;
			if ($revmod::playerMove[0] eq "q" ) {
				die "Dzięki za grę\n";
			} else {
				revmod::makeMove($revmod::playerMove[0], $revmod::playerMove[1], $revmod::playerTile);
			}
			revmod::getValidMoves($revmod::computerTile);
			print $#revmod::validMoves;
			if ($#revmod::validMoves <= 0) {
				last
			} else {
				$turn = 'komputer';
			}
		}
		else
		{
			revmod::drawBoard;
			revmod::showScore($revmod::playerTile, $revmod::computerTile);
			print "Wciśnij Enter aby komputer wykonał ruch";
			<>;
			revmod::getComputerMove;
			revmod::makeMove($revmod::computerMove[0], $revmod::computerMove[1], $revmod::computerTile);
			revmod::getValidMoves($revmod::playerTile);
			if ($#revmod::validMoves <= 0) {
				last
			} else {
				$turn = 'gracz';
			}
		}
		revmod::clearScreen;
	}
	
	#wynik gry
	revmod::clearScreen;
	revmod::drawBoard;
	revmod::getScoreBoard;
	revmod::showScore($revmod::playerTile, $revmod::computerTile);
	if ($revmod::score{$revmod::playerTile} > $revmod::score{$revmod::computerTile}) {
		print "Pokonałeś komputer ", $revmod::score{$revmod::playerTile} - $revmod::score{$revmod::computerTile}, " pkt. Gratulacje!\n";
	} elsif ($revmod::score{$revmod::playerTile} < $revmod::score{$revmod::computerTile}) {
		print "Przegrałeś. Komputer pokonał cię ", $revmod::score{$revmod::computerTile} - $revmod::score{$revmod::playerTile}, " pkt.\n";
	} else {
		print "Remis.\n";
	}
	
	if (!revmod::playAgain){
		last;
	}
}
