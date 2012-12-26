PoolRank
========

PoolRank generates a round-robin tournament matches from a player list and
saves it to a CSV file which you can use to keep track of your match result.
The results will be gathered to create a standings table that show how well
you play comparing to other players. It also displays past results and
suggests remaining matches until all games are being played out.

Getting Started
---------------

Clone the PoolRank repo at the command prompt:

    $ git clone https://github.com/wulab/poolrank.git

Change directory to `poolrank` and create a config file:

    $ cd poolrank
    $ cp pool.yml.example pool.yml

Then, run the program:

    $ ruby pool.rb

Player List
-----------

Player list resides in `pool.yml`. You can edit the file to add/remove player
and regenerate a new set of matches by:

    $ rm pool.csv
    $ ruby pool.rb

Please beware that this will remove any previous result. If you want to update
the list during a tournament, please backup `pool.csv` file before doing so.

Match Results
-------------

PoolRank reads match results from `pool.csv`. This file will be generated the
first time you run the program with the following format:

    player1,player2,result

You can record your match result directly to `pool.csv` by editing the number
at the end of each line, providing that `0 = unplayed, 1 = win, -1 = lose`.

License
-------

PoolRank is released under the [MIT License][1].

[1]: http://www.opensource.org/licenses/MIT