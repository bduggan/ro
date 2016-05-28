[![Build Status](https://travis-ci.org/bduggan/ro.svg?branch=master)](https://travis-ci.org/bduggan/ro)

This is a simple backend to play rock-paper-scissors.

A front-end can be found be found here: <https://github.com/ryanhinkel/rockpaperscissors>.

A sample deployment is at <http://play.promptworks.com>.

```
1. Install deps.

   Install perlbrew from http://perlbrew.pl
   (and add 'source ~/perl5/perlbrew/etc/bashrc' to ~/.bash_profile)
   perlbrew install perl-5.22.0
   perlbrew switch perl-5.22.0
   perlbrew install-cpanm
   cpanm --installdeps .

2. Test.

  ./ro test

3. Optional:

   Copy ro.conf.example to ro.conf and change the values.

4. Run.

    ./ro daemon

5. Deploy:

    hypnotoad ./ro

```
