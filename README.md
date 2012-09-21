http_check_redirect script for Nagios, originally written by [Eugene L
Kovalenja](http://exchange.nagios.org/directory/Plugins/Websites,-Forms-and-Transactions/Check-Http-Redirect/details)

It retrieves an http/s url and checks its header for a given redirects.  If
the redirect exists and equal to the redirect you entered then exits with OK,
otherwise exits with WARNING (if not equal) or CRITICAL ( if doesn't exist)

The customised version supports virtual hosts parameter which is useful for
redirect checks on the servers behind loadbalancers.
