package Number::Phone::NO;

# ABSTRACT: Number::Phone country package for NO (Norway)

use warnings;
use strict;
use Carp;

use base qw(Number::Phone);
use Scalar::Util 'blessed';
use Number::Phone;
use Number::Phone::NO::Data;

$Number::Phone::subclasses{country_code()} = __PACKAGE__;

my $cache = {};

sub new {
    my $class = shift;
    my $number = shift;
    die("No number given to ".__PACKAGE__."->new()\n") unless($number);
    return bless(\$number, $class) if(is_valid($number));
}


sub country_code {
    return 47;
}
sub subscriber {
    my $self = shift;
	$self = shift if($self eq __PACKAGE__);
	$self = __PACKAGE__->new($self)
	    unless(blessed($self) && $self->isa(__PACKAGE__));
	return unless ($self and blessed($self) and $self->isa(__PACKAGE__));
    my $parsed_number = $$self;
    $parsed_number =~ s/[^0-9+]//g;               # strip non-digits/plusses
    $parsed_number =~ s/^\+47//;                  # remove leading +47
    return $parsed_number;
}
sub regulator {
    'Post- og teletilsynet, http://www.npt.no/';
}
foreach my $is (qw(
    fixed_line geographic network_service tollfree corporate
    personal pager mobile specialrate adult allocated ipphone
)) {
    no strict 'refs'; ## no critic
    *{__PACKAGE__."::is_$is"} = sub {
        my $self = shift;
    	$self = shift if($self eq __PACKAGE__);
    	$self = __PACKAGE__->new($self)
    	    unless(blessed($self) && $self->isa(__PACKAGE__));
    	$self && $cache->{$$self} ? $cache->{$$self}->{"is_$is"} : undef;
    }
}

foreach my $method (qw(operator areacode areaname location )) {
    no strict 'refs'; ## no critic
    *{__PACKAGE__."::$method"} = sub {
        my $self = shift;
        $self = (blessed($self) && $self->isa(__PACKAGE__)) ?
            $self :
            __PACKAGE__->new($self);
        return $cache->{${$self}}->{$method};
    }
}

sub is_valid {
    my ($number) = @_;
    return 1 if(blessed($number) && $number->isa(__PACKAGE__));
    
    return 1 if($cache->{$number}->{is_valid});
    
    my $parsed_number = $number;
    $parsed_number =~ s/[^0-9+]//g;               # strip non-digits/plusses
    $parsed_number =~ s/^\+47//;                  # remove leading +47
    
    
    # a norwegian phone number can be one of two forms:
    # +4712345678
    #    12345678

    my $bucket = Number::Phone::NO::Data::lookup($parsed_number);
    
    $cache->{$number} = $bucket;
    
    return $cache->{$number}->{is_valid};
}

sub format {
    my $self = shift;
    $self = (blessed($self) && $self->isa(__PACKAGE__)) ?
        $self :
        __PACKAGE__->new($self);
    my $nr = $self->subscriber();
    my @digits = split(//, $nr);
    my $format = ($self->is_mobile || $self->is_specialrate || $self->is_tollfree
        ? "%d%d%d %d%d %d%d%d"
        : "%d%d %d%d %d%d %d%d");
    $format = "%d"x scalar(@digits) unless (scalar(@digits) == 8);

#    warn "format: $format, " . join(", ", @digits);
    return '+'.country_code()  . " " . sprintf($format, @digits);
}
1; # Magic true value required at end of module
__END__

=head1 SYNOPSIS

    use Number::Phone;
    use Number::Phone::NO;

    Number::Phone::NO::is_valid("+47 2234 5123");

    my $s = Number::Phone::NO::format("2234 5123");
    $s eq "+47 22 34 51 23"


=head1 DESCRIPTION

Number::Phone::NO tries to provide the Number::Phone framework with support
for norwegian phone numbers. Its data is based on the number plans provided
by Post- og teletilsynet, which is a govermental institution.


=method new $nr

Takes a number as its only argument, returning a blessed object if the
number is valid, or undef on invalid.

=method areacode

Never returns anything, as we do not have reliable area-codes in Norway.

=method format

Formats the numbers according to Post- og teletilsynets recomendations.

=method operator

Returns the company that has been assigned the range the number lives in.
Due to portability of numbers in Norway, this may no longer be the right
operator.

=method country_code

Returns 47, which is the norwegian country code

=method location

Never returns anything since there is no way to tell from the public
information.

=method regulator

Always returns Post- og teletilsynet

=method subscriber

Returns the 3-8 digits part of the phonenumer that isn't the country_code

=method areaname

Returns the name of the area the number was originaly allocated for. Due
to number portability, this may no longer be the right area.

=method is_adult

Returns true for numbers in the ranges marked as premium rate services

=method is_allocated

Returns true for all numbers in ranges not marked as reserve or available

=method is_corporate

Always returns undef, as the data is inconclusive.

=method is_fixed_line

Always returns undef, as the data is inconclusive.

=method is_geographic

Always returns undef, as the data is inconclusive.

=method is_ipphone

Returns true for numbers within the ranges marked with IP

=method is_mobile

Returns true for numbers within tanges marked with GSM

=method is_network_service

Returns true for numbers in the 100-199 range, which includes emergency
service etc.

=method is_pager

Returns undef, as the data is inconclusive.

=method is_personal

Returns undef, as the data is inconclusive.

=method is_specialrate

Returns true for numbers that are marked as some type of rate in the data

=method is_tollfree

Returns true for numbers marked as reversed charge

=method is_valid

Returns true if the number falls within a range.

=head1 CONFIGURATION AND ENVIRONMENT

Number::Phone::NO requires no configuration files or environment variables.

