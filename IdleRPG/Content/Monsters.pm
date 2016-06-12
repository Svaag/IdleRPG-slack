package Monsters;

use IdleRPG::IRC;

sub getList {
my %monster;
#### Monsters ####

###$monster{"XXX"}{gain} = 5;
###$monster{"XXX"}{regen} = 2;
###$monster{"XXX"}{goldm} -> $monster{"XXX"}{gold}

$monster{"Roach"}{sum} = 500;
$monster{"Roach"}{gold} = 0;
$monster{"Roach"}{gem} = 1;
$monster{"Spider"}{sum} = 1000;
$monster{"Spider"}{gold} = 250;
$monster{"Spider"}{gem} = 0;
$monster{"Bat"}{sum} = 2000;
$monster{"Bat"}{gold} = 0;
$monster{"Bat"}{gem} = 2;
$monster{"Wolf"}{sum} = 3000;
$monster{"Wolf"}{gold} = 400;
$monster{"Wolf"}{gem} = 0;
$monster{"Goblin"}{sum} = 4000;
$monster{"Goblin"}{gold} = 0;
$monster{"Goblin"}{gem} = 3;
$monster{"Shadow"}{sum} = 5000;
$monster{"Shadow"}{gold} = 500;
$monster{"Shadow"}{gem} = 0;
$monster{"Lich"}{sum} = 6000;
$monster{"Lich"}{gold} = 0;
$monster{"Lich"}{gem} = 4;
$monster{"Skeleton"}{sum} = 7000;
$monster{"Skeleton"}{gold} = 700;
$monster{"Skeleton"}{gem} = 0;
$monster{"Ghost"}{sum} = 8000;
$monster{"Ghost"}{gold} = 0;
$monster{"Ghost"}{gem} = 5;
$monster{"Phantom"}{sum} = 9000;
$monster{"Phantom"}{gold} = 800;
$monster{"Phantom"}{gem} = 0;
$monster{"Troll"}{sum} = 10000;
$monster{"Troll"}{gold} = 0;
$monster{"Troll"}{gem} = 6;
$monster{"Cyclop"}{sum} = 12000;
$monster{"Cyclop"}{gold} = 1000;
$monster{"Cyclop"}{gem} = 0;
$monster{"Mutant"}{sum} = 14000;
$monster{"Mutant"}{gold} = 0;
$monster{"Mutant"}{gem} = 8;
$monster{"Ogre"}{sum} = 17000;
$monster{"Ogre"}{gold} = 1400;
$monster{"Ogre"}{gem} = 0;
$monster{"Phoenix"}{sum} = 21000;
$monster{"Phoenix"}{gold} = 0;
$monster{"Phoenix"}{gem} = 10;
$monster{"Demon"}{sum} = 25000;
$monster{"Demon"}{gold} = 1700;
$monster{"Demon"}{gem} = 0;
$monster{"Centaur"}{sum} = 30000;
$monster{"Centaur"}{gold} = 0;
$monster{"Centaur"}{gem} = 12;
$monster{"Werewolf"}{sum} = 35000;
$monster{"Werewolf"}{gold} = 2000;
$monster{"Werewolf"}{gem} = 0;
$monster{"Giant"}{sum} = 40000;
$monster{"Giant"}{gold} = 0;
$monster{"Giant"}{gem} = 15;
$monster{"Siren"}{sum} = 45000;
$monster{"Siren"}{gold} = 2400;
$monster{"Siren"}{gem} = 0;
$monster{"Chimera"}{sum} = 50000;
$monster{"Chimera"}{gold} = 0;
$monster{"Chimera"}{gem} = 18;
$monster{"Hippogriff"}{sum} = 55000;
$monster{"Hippogriff"}{gold} = 2800;
$monster{"Hippogriff"}{gem} = 0;
$monster{"Minotaur"}{sum} = 60000;
$monster{"Minotaur"}{gold} = 0;
$monster{"Minotaur"}{gem} = 21;
$monster{"Wyvern"}{sum} = 65000;
$monster{"Wyvern"}{gold} = 3200;
$monster{"Wyvern"}{gem} = 0;
$monster{"Behemoth"}{sum} = 70000;
$monster{"Behemoth"}{gold} = 0;
$monster{"Behemoth"}{gem} = 24;
$monster{"Leviathan"}{sum} = 75000;
$monster{"Leviathan"}{gold} = 3700;
$monster{"Leviathan"}{gem} = 0;
$monster{"Faerie_Queen"}{sum} = 80000;
$monster{"Faerie_Queen"}{gold} = 0;
$monster{"Faerie_Queen"}{gem} = 28;
$monster{"Gold-Hoarding_Goblin"}{sum} = 85000;
$monster{"Gold-Hoarding_Goblin"}{gold} = 4300;
$monster{"Gold-Hoarding_Goblin"}{gem} = 0;

return %monster;

}

sub get_monst_name {
    my $monsum = shift;
    my $monname = "Monster";
    if (!open(Q,$Options::opts{monstfile})) {
        IRC::chanmsg("ERROR: Failed to open $Options::opts{monstfile}: $!");
        return $monname;
    }
    while (my $line = <Q>) {
        chomp($line);
        if ($line =~ /^(\d+) ([^\r]*)\r*/) {
            if ($1 >= $monsum) {
                $monname = $2;
                last();
            }
        }
    }
    close(Q);
    return $monname;
}

1;
