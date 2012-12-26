Oozou PoolRank
==============

Pool game matchmaking, score keeping and player ranking.

Getting Started
---------------

Clone the PoolRank repo at the command prompt:

    $ git clone git://github.com/oozou/poolrank.git

Change directory to `poolrank` and run the program:

    $ cd poolrank
    $ ruby pool.rb

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