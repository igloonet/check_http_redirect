#!/usr/bin/perl -w

#------------------------------------------------------------------------------
# Nagios check_http_redirect
#   retrieve an http/s url and checks its header for a given redirects
#   if the redirect exists and equal to the redirect you entered then exits with OK, otherwise exits with WARNING (if not equal) or CRITICAL ( if doesn't exist)
#
# Copyright 2009, Eugene L Kovalenja, http://www.purple.org.ua/
# Copyright 2012, Ruslan Kabalin, Lancaster University, UK
# Licensed under GPLv2
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with Opsview; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# -----------------------------------------------------------------------------

use strict;
use Getopt::Std;
use LWP::UserAgent;
use HTTP::Request;

my $plugin_name = 'Nagios check_http_redirect';
my $VERSION     = '1.01';

# getopt module config
$Getopt::Std::STANDARD_HELP_VERSION = 1;

# nagios exit codes
use constant EXIT_OK        => 0;
use constant EXIT_WARNING   => 1;
use constant EXIT_CRITICAL  => 2;
use constant EXIT_UNKNOWN   => 3;


# parse cmd opts
my %opts;
getopts('vU:R:t:H:', \%opts);
$opts{t} = 5 unless (defined $opts{t});
if (not (defined $opts{U} ) or not (defined $opts{R} )) {
    print "ERROR: INVALID USAGE\n";
    HELP_MESSAGE();
    exit EXIT_CRITICAL;
}

my $status = EXIT_OK;

my $ua = LWP::UserAgent->new;

$ua->agent('check_http_redirect' . $VERSION);
$ua->protocols_allowed( [ 'http', 'https'] );
$ua->parse_head(0);
$ua->timeout($opts{t});
$ua->max_redirect(0);

my $request = new HTTP::Request('GET', $opts{U});

if (defined $opts{H})
{
    $request->header('Host', $opts{H});
}

#DEBUG:  print $request->as_string;
my $response = $ua->request($request);
#DEBUG:  print $response->as_string;

if ($response->is_success or $response->is_error)
{
    print "REDIRECT ERROR: Current HTTP response status line: ", $response->status_line, ". Check this page: $opts{U}\n";
    $status = EXIT_CRITICAL;
}
else
{
    if ($response->is_redirect)
    {
        if ( $response->header("Location") =~ $opts{R} )
        {
            print "REDIRECT OK: ", $response->status_line, " ", $response->header("Location"), "\n";
            $status = EXIT_OK;
        }
        else
        {
            print "REDIRECT WARNING: Location is invalid: ",$response->status_line, " ", $response->header("Location"), "\n";
            $status = EXIT_WARNING;
        }
    }
    else
    {
        print "REDIRECT ERROR: cannot retrieve the url: ", $response->status_line, "\n";
        $status = EXIT_UNKNOWN;
    }
}

exit $status;

sub HELP_MESSAGE
{
    print <<EOHELP
    Retrieve an http/s url and checks its header for a given redirects.
    If the redirect exists and equal to the redirect you entered then exits with OK, otherwise exits with WARNING (if not equal) or CRITICAL ( if doesn't exist)

    --help      shows this message
    --version   shows version information

    -U          URL to retrieve (http or https)
    -R          URL that must be equal to Header Location Redirect URL
    -H          Optional host attribute, useful if you are querying
                virtual host. If using, URL to retrieve should contain the real host
                name or IP of the webserver.
    -t          Timeout in seconds to wait for the URL to load. If the page fails to load,
                $plugin_name will exit with UNKNOWN state (default 60)

EOHELP
;
}


sub VERSION_MESSAGE
{
    print <<EOVM
$plugin_name v. $VERSION
Copyright 2009, Eugene L Kovalenja, http://www.purple.org.ua/ - Licensed under GPLv2
Copyright 2012, Ruslan Kabalin, Lancaster University, UK - Licensed under GPLv2
EOVM
;
}
# vi: tabstop=4 shiftwidth=4 expandtab
