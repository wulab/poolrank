Oozou PoolRank
==============

Pool game matchmaking, score keeping and player ranking.

Getting Started
---------------

Clone the PoolRank repo at the command prompt:

    $ git clone git://github.com/oozou/poolrank.git

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

Recording Results
-----------------

PoolRank reads game results from `pool.csv`. It will be generated the first
time you run the program with the following format:

    player1,player2,result

You can record game result directly to `pool.csv` by editing the result number
at the end of each line, providing 0 = unplayed, 1 = win, -1 = lose.

License
-------

PoolRank is released under the [MIT License][1].

[1]: http://www.opensource.org/licenses/MIT