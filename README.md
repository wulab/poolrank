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

Change directory to `poolrank` and run the program:

    $ cd poolrank
    $ ruby pool.rb

Edit company and player list in `pool.yml` and run the program again:

    $ ruby pool.rb

Tournament matches will be generated in `pool.yml`.

Player List
-----------

Player list resides in `pool.yml`. You can edit the file to add/remove player
and regenerate a new set of matches by removing the matches section from the
file. Be sure to backup any match results before doing so.

Match Results
-------------

PoolRank reads match results from the matches section in `pool.yml`. This
section will be generated from player list if not exists. It is currently
written in the following format:

    player1,player2,result

You can record your match result directly to `pool.yml` by editing the number
at the end of each line, providing that `0 = unplayed, 1 = win, -1 = lose`.

License
-------

PoolRank is released under the [MIT License][1].

[1]: http://www.opensource.org/licenses/MIT