#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket;
use IO::Select;
use Data::Dumper;
use Getopt::Long;
use Tie::SubstrHash;
use File::Slurp;
use Encode;
use JSON;
use DBI;
use IdleRPG::Bot;
use IdleRPG::Database;
use IdleRPG::Constants ':locations';
use IdleRPG::Constants ':classes';
use IdleRPG::IRC;
use IdleRPG::Slack;
use IdleRPG::RNG;
use IdleRPG::Options;
use IdleRPG::Simulation;
use IdleRPG::Content::Monsters;
use IdleRPG::Content::Dragons;
use IdleRPG::Gameplay::PVE;
use IdleRPG::Gameplay::PVP;
use IdleRPG::Gameplay::Equipment;
use IdleRPG::Gameplay::Events;
use IdleRPG::Gameplay::Level;
use IdleRPG::Gameplay::Store;
use IdleRPG::Gameplay::Quests;
use IdleRPG::Gameplay::World;
use IdleRPG::Gameplay::Tournaments;
our $version = "1.0.0";

# Load database
Database::checkdbfile();

# Daemonize
Bot::daemonize();

# Start up the game loop! 
IdleRPG::Slack::start();


