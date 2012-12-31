PoolRank
========

PoolRank generates a round-robin tournament matches from a player list and
saves it to an YAML file which you can use to keep track of your match result.
The results will be gathered to create a standings table that show how well
you play comparing to other players. It also displays past results and
suggests remaining matches until all games are being played out.

Getting Started
---------------

Clone the PoolRank repo at the command prompt:

    $ git clone https://github.com/wulab/poolrank.git

Change directory to `poolrank` and create an initial data file:

    $ cd poolrank
    $ ruby pool.rb init

Edit company and player list in `pool.yml` then create a new tournament:

    $ ruby pool.rb new

Tournament matches will be generated in `pool.yml`. Now run the program
to see tournament summary:

	$ ruby pool.rb show

Player List
-----------

Player list resides in `pool.yml`. You can edit the file to add/remove player
and regenerate a new set of matches by:

	$ ruby pool.rb new

Be sure to backup your match results before doing so.

Match Results
-------------

PoolRank reads match results from the matches section in `pool.yml`. This
section will be generated from player list if not exists. It is currently
written in the following format:

    player1,player2,result

You can record your match result directly to `pool.yml` by editing the number
at the end of each line, providing that `0 = unplayed, 1 = win, -1 = lose`.

Data File
---------

For display commands (e.g. show, standings), you can specify external data
file as an optional argument to the command:

	$ ruby pool.rb show company.yml
	$ ruby pool.rb standings /path/to/file/pool.yml

PoolRank will read tournament data from that file instead of the default
`pool.yml`.

License
-------

PoolRank is released under the [MIT License][1].

[1]: http://www.opensource.org/licenses/MIT