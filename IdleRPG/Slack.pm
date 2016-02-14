package IdleRPG::Slack;

use AnyEvent;
use AnyEvent::SlackRTM;
use WebService::Slack::WebApi;
use Sub::Throttler qw( throttle_it );
use Sub::Throttler::Rate::AnyEvent;
use Encode;
use JSON;
use strict;
use warnings;

# Slack API info
my $access_token = $Options::opts{token};
our $slack_api = WebService::Slack::WebApi->new(token => $access_token);
our $slack_rtm = AnyEvent::SlackRTM->new($access_token);

our $throttle = Sub::Throttler::Rate::AnyEvent->new(period => 15, limit => 15);
throttle_it('AnyEvent::SlackRTM::send');

$throttle->apply_to_methods("AnyEvent::SlackRTM" => qw( send ));

# Setup event listeners, connect to Slack and start the game loop
sub start {
my $keep_alive;
my $tick;
my $backup;
our %slack_info;
my $cond = AnyEvent->condvar;

    # Slack API sends hello when connection is confirmed 
    # It means we are ready to go!
    $slack_rtm->on('hello' => sub { 
        Bot::debug("Received hello from Slack. Setting up the game...\n");

        # Get information about bot connection
        %slack_info = get_slack_info();
        use Data::Dumper;
        print Dumper(%slack_info);

        # We need to send pings in order to keep the connection
        $keep_alive = AnyEvent->timer(interval => 30, cb => sub {
            $slack_rtm->ping;
            Bot::debug("Ping\n");
        });

        # Tick the game engine 
        $tick = AnyEvent->timer(interval => 2, cb => sub {
            Bot::debug("Engine Tick\n");
            Simulation::rpcheck();
        });

        # Backup the JSON DB file
        $backup = AnyEvent->timer(interval => 300, cb => sub {
            Bot::debug("Database Backup\n");
            Database::regular_backup();
        });

    });

    # Log pongs to our keepalives
    $slack_rtm->on('pong' => sub {
        my ($slack_rtm, $pong) = @_;
            Bot::debug("Pong\n");
        });

    # Handle messages sent to the bot and bot chan
    $slack_rtm->on('message' => sub { 
        my ($slack_rtm, $message) = @_;
        Bot::debug("< $message->{text}, $message->{user}\n");
 
        # Get username and direct message channel ID from Slack UserID
        # TODO: This spams the API so should be read from metadata instead.
        my $username = get_username_from_id($message->{user});
        my $channel_id = $message->{channel};

        # Send message to IRC parser. Needs to be rewritten for Slack!
        if ($channel_id eq $IdleRPG::Slack::slack_info{game_chan_id}) {
            IRC::parse("$username privmsg $Options::opts{botchan} $message->{text}");
        } else {
            IRC::parse("$username privmsg $Options::opts{botnick} $message->{text}");
        }
    });

    # Handle Error responses from RTM api
    $slack_rtm->on('error' => sub { 
        my ($slack_rtm, $error) = @_;
        Bot::debug("Slack ERROR: $error->{error}{msg}\n");
    });

    #TODO: Handle Slack connection being closed with something fancy
    $slack_rtm->on('finish' => sub { 
        Bot::debug("Done\n");
        $cond->send;
    });
 
    Bot::debug("Game setup. Starting!");

    # Start up the game loop and event listener!
    $slack_rtm->start;
    AnyEvent->condvar->recv;

}

# Get metadata from Slack RTM api setup and parse to hash
sub get_slack_info {
    # Hash containing metadata
    my %slack_info;

    # Get metadata for our connection to Slack
    my $metadata = $IdleRPG::Slack::slack_rtm->metadata;

    # Get the bot's Slack UserID 
    my $user_id = $metadata->{self}->{id};

    # Get the bot's Slack Direct Message Channel ID
    my $channel_id;
    my $bot_chan = $Options::opts{botchan};
    $bot_chan =~ s/#//;
   
    # Look thjrough channels array to find Game Channel ID
    for my $channel( @{$metadata->{channels}} ){
       if ($channel->{name} eq $bot_chan) {
           $channel_id = $channel->{id};
       }
    };

    # Create slack_info hash
    $slack_info{bot_chan_id} = $user_id;
    $slack_info{game_chan_id} = $channel_id;

    return %slack_info;

}

# Get Slack User ID from username
sub get_id_from_username {
    my $username = shift;
    my $id;

    # Get list of users from Slack API
    my $users_list = $IdleRPG::Slack::slack_api->users->list;

    # Look through members array to find  ID of the user
    for my $member( @{$users_list->{members}} ){
       if ($member->{name} eq $username) {
          $id = $member->{id};
       }
    };

    return $id;

}

# Get Slack username from UserID
sub get_username_from_id {
    my $id = shift;

    # Get information from Slack API
    my $info = $IdleRPG::Slack::slack_api->users->info(
                               user => $id,
                               );

    my $username = $info->{user}->{name};

}

# Get direct message Slack Channel ID
sub get_im_channel_id_from_user_id {
    my $user_id = shift;
    my $im_channel_id;

    # Get list of IM conversations
    my $im_list = $IdleRPG::Slack::slack_api->im->list;

    # Look through IM array for our user
    for my $im( @{$im_list->{ims}} ){
        if ($im->{user} eq $user_id) {
            $im_channel_id = $im->{id};
        }
    };

    return $im_channel_id;

}

# Send direct message to a user.
sub send_direct_message {
    my($text,$user) = @_;

    # First get User ID from Username and then the user's IM channel ID from the User ID
    # TODO: This spams the API so should be read from metadata instead
    my $user_id = get_id_from_username($user);
    my $im_channel_id = get_im_channel_id_from_user_id($user_id);
        Bot::debug("$user_id $im_channel_id");
        Bot::debug("> $text, $user\r\n");

        # Send direct message
        $IdleRPG::Slack::slack_rtm->send({
              type => 'message',
              channel => $im_channel_id,
              text => $text,
          });

        Bot::debug("> $text, $user\r\n");
   
    return 0;

}

# Send a message to the game channel
sub send_channel_message {
    my $text = shift;
    my $channel = $IdleRPG::Slack::slack_info{game_chan_id};

    Bot::debug("> $text, $channel\r\n");

        # Send channel message
        $IdleRPG::Slack::slack_rtm->send({
              type => 'message',
              channel => $channel,
              text => $text,
          });

    return 0;

}

1;
