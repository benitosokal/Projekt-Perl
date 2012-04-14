package revmod;

#funkcja rysująca plansze
sub drawBoard
{
	$HLINE = "  +---+---+---+---+---+---+---+---+\n";
	print "    1   2   3   4   5   6   7   8\n";
	print $HLINE;
	for my $y (0 .. 7)
	{
		print $y+1, ' ';
		for my $x (0 .. 7)
		{
			print "| $board[$x][$y] ";
		}
		print "|\n";
		print $HLINE;
	}
}

#funkcja tworząca nową planszę
sub getNewBoard
{
	for my $x (0 .. 7) {                       
		for my $y (0 .. 7) {                   
			$board[$x][$y] = ' ';    
		}
	}
}
#resetuje planszę
sub resetBoard
{
	for my $x (0 .. 7) {                       
		for my $y (0 .. 7) {                   
			$board[$x][$y] = ' ';    
		}
	}
	
	$board[3][3] = 'X';
    $board[3][4] = 'O';
    $board[4][3] = 'O';
    $board[4][4] = 'X';
}

#funkcja sprawdza czy ruch jest prawidłwoy 
#jeśli tak tworzy tablice współrzędnych na których trzeba zmienić kolor pionka
sub isValidMove
{
	my $xstart = shift;
	my $ystart = shift;
	my $tile = shift;
	
	if (($board[$xstart][$ystart] ne " ") || (!isOnBoard($xstart, $ystart))) {
		return 0; 
	}
	
	$board[$xstart][$ystart] = $tile;
	
	if ($tile eq 'X') {
        $otherTile = 'O'
	} else {
        $otherTile = 'X'
	}
	
	undef @tilesToFlip;
	
	foreach $xdir (-1, 0, 1)
	{
		foreach $ydir (-1, 0, 1) 
		{
			next if ( $xdir == 0 && $ydir == 0 );
			my $x = $xstart;
			my $y = $ystart;
			$x += $xdir;
			$y += $ydir;
			if ( !isOnBoard($x, $y)) {
				next;
			}
			while ( $board[$x][$y] eq $otherTile )
			{
				$x += $xdir;
				$y += $ydir;
				if ( !isOnBoard($x, $y)) {
					last;
				}
			}
			if ( !isOnBoard($x, $y)) {
				next;
			}
			if ($board[$x][$y] eq $tile )
			{
				while (1)
				{
					$x -= $xdir;
					$y -= $ydir;
					if ( $x == $xstart && $y == $ystart ) {
						last;
					}
					push @tilesToFlip, ( $x, $y );
				}
			}
		}
	}
	$board[$xstart][$ystart] = ' ';
	
	if ($#tilesToFlip <= 0) {
		return 0;
	}
	return 1;
}

#funkcja sprawdzająca czy podane współrzędne znajdują się na planszy
sub isOnBoard
{	
	my $x = shift;
	my $y = shift;
	if ($x >= 0 && $x <= 7 && $y >= 0 && $y <=7) {
		return 1;
	} else {
		return 0;
	}
}

#funkcja liczący ile jest na planszy X i O
sub getScoreBoard
{
	%score = ( "X" => 0, "O" => 0 );
	
	for my $x (0 .. 7) {                       
		for my $y (0 .. 7) {                   
			if ($board[$x][$y] eq 'X') {
				++$score{"X"};
			}
			if ($board[$x][$y] eq 'O') {
				++$score{"O"};
			}
		}
	}
}

#funkcja pytające gracza czy chce grać X lub O
sub choseTile
{
	my $tile = '';
	while (!($tile eq 'X' || $tile eq 'O'))
	{
		print "Chcesz grać X lub O:";
		$tile = <STDIN>;
		chomp $tile;
		$tile = ucfirst($tile);
	}
	
	if ($tile eq 'X') {
		$playerTile = 'X';
		$computerTile = 'O';
	} else {
		$playerTile = 'O';
		$computerTile = 'X';
	}
}

#funkcja losuje kto zaczyna rozgrywkę
sub whoGoesFirst
{
	if (int(rand(2))) {
		return 'komputer';
	} else {
		return 'gracz';
	}
}

#funkcja wyświetlająca wyniki
sub showScore
{
	my $player = shift;
	my $comp = shift;
	getScoreBoard;
	print "Masz $score{$player} punktów. Komputer ma $score{$comp}.\n";
}

#wykonaj ruch jeśli dozwolony w przeciwnym razie zwróć false
sub makeMove
{
	my $xstart = shift;
	my $ystart = shift;
	my $tile = shift;
	 
	if (isValidMove($xstart, $ystart, $tile) == 0) {
		return 0;
	}
	
	$board[$xstart][$ystart] = $tile;
	for (my $i = 0; $i < $#tilesToFlip; $i += 2)
	{
		$board[$tilesToFlip[$i]][$tilesToFlip[$i + 1]] = $tile;
	}
	return 1;
}

#pobiera ruch od gracza
sub getPlayerMove
{
	my $move = '';
	while (1)
	{
		print "Wpisz ruch albo wpisz q zakończyć grę:\n";
		$move = <STDIN>;
		chomp $move;
		$move = lc($move);
		@playerMove = split(//, $move);
		if ($playerMove[0] eq "q" )
		{
			last;
		}
		if ($playerMove[0] =~ /^[12345678]$/ && $playerMove[1] =~ /^[12345678]$/)
		{
			--$playerMove[0];
			--$playerMove[1];
			if (!isValidMove($playerMove[0], $playerMove[1], $playerTile))
			{
				print "Nieprawidłowy ruch.\n";
				next;
			} else {
				last;
			}
		}
		print "To nie jest prawidłowy ruch. Najpierw wpisz numer kolumny (1-8),\n";
		print "a potem numer wiersza (1-8)\n";
		print "Na przykła 81 wskaże prawy górny róg\n";
	}
}

#pobiera ruch komputera
sub getComputerMove
{
	getValidMoves($computerTile);
	print @ValidMoves;
	
	for (my $i = 0; $i < $#validMoves; $i += 2)
	{
		if (isOnCorner($validMoves[$i], $validMoves[$i + 1])) {
			@computerMove = ( $validMoves[$i], $validMoves[$i + 1]);
			return;
		}
	}
	my $bestScore = -1;
	for (my $i = 0; $i < $#validMoves; $i += 2)
	{
		getBoardCopy;
		makeMoveOnCopy($validMoves[$i], $validMoves[$i + 1], $computerTile);
		my $score = getCopyBoardScore;
		if ($score > $bestScore) {
			@bestMove = ($validMoves[$i], $validMoves[$i + 1]);
			$bestScore = $score;
		}
	}
	@computerMove = ($bestMove[0], $bestMove[1]);
}

#tworzy kopie planszy dla komputera
sub getBoardCopy
{
	undef $boardCopy;
	
	for my $x (0 .. 7) {                       
		for my $y (0 .. 7) {                   
			$boardCopy[$x][$y] = $board[$x][$y];
		}
	}
}

#wykonuje ruch na kopi planszy
sub makeMoveOnCopy
{
	my $xstart = shift;
	my $ystart = shift;
	my $tile = shift;
	 
	if (isValidMove($xstart, $ystart, $tile) == 0) {
		return 0;
	}
	
	$boardCopy[$xstart][$ystart] = $tile;
	for (my $i = 0; $i < $#tilesToFlip; $i += 2)
	{
		$boardCopy[$tilesToFlip[$i]][$tilesToFlip[$i + 1]] = $tile;
	}
	return 1;
}

#zwracy aktualny wynik na planszy
sub getCopyBoardScore
{
	my $copyBoardScore = 0;
	for my $x (0 .. 7) {                       
		for my $y (0 .. 7) {                   
				if ($boardCopy[$x][$y] eq $computerTile) {
					++$copyBoardScore;
			}
		}
	}
	return $copyBoardScore;
}

#sprawdza czy współrzędne to róg planszy
sub isOnCorner
{
    my $x = shift;
	my $y = shift; 
    if (($x == 0 && $y == 0) || ($x == 7 && $y == 0) || ($x == 0 && $y == 7) || ($x == 7 && $y == 7))
	{
		return 1;
	} else {
		return 0;
	}
}

#znajduje współrzędne wszystkich możliwych ruchów na aktualnej planszy
sub getValidMoves
{
	undef @validMoves;
	my $tile = shift;
	
	for my $x (0 .. 7) {                       
		for my $y (0 .. 7) {                   
			if (isValidMove($x, $y, $tile)) {
				push @validMoves, ($x, $y);
			}
		}
	}
}

sub playAgain
{
	print "Chcesz zagrać jeszcze raz? (t/n):";
	$qst = <STDIN>;
	chomp $qst;
	$qst = lc($qst);
	@playAgain = split(//, $qst);
	if ($playAgain[0] eq 't') {
		return 1;
	} else {
		return 0;
	}
}

sub clearScreen
{
	system $^O eq 'MSWin32' ? 'cls' : 'clear';

}

1;
