package FilterTest;
# should be separated into Filter testing module.

use strict;
use vars qw(@ISA @EXPORT);

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(filters);

# Can't load Apache::File
require FileHandle;
@Apache::File::ISA = qw(FileHandle);

use Apache::FakeRequest;

sub filters {
    my($file, $class, $config) = @_;
    tie *STDOUT, 'Tie::STDOUT', \my $output;
    my $r = Apache::FakeRequest->new(
	content_type => 'text/html',
	is_main => 1,
	filename => $file,
    );

    if (ref($config) eq 'HASH') {
	no strict 'refs';
	local $^W;		# subroutine redefined warning
	*{"Apache::FakeRequest::dir_config"} = sub {
	    my($r, $cfgkey) = @_;
	    return $config->{$cfgkey};
	};
    }	

    no strict 'refs';
    &{$class. "::handler"}($r);
    return $output;
}

package Tie::STDOUT;

sub TIEHANDLE {
    my($class, $ref) = @_;
    bless $ref, $class;
}

sub PRINT {
    my $self = shift;
    $$self .= join '', @_;
}


1;
