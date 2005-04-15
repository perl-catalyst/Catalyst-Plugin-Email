package Catalyst::Plugin::Email;

use strict;
use Email::Send;
use Email::MIME;
use Email::MIME::Creator;

our $VERSION = '0.04';

=head1 NAME

Catalyst::Plugin::Email - Send emails with Catalyst

=head1 SYNOPSIS

    use Catalyst 'Email';

    __PACKAGE__->config->{email} = [qw/SMTP smtp.oook.de/];

    $c->email(
        header => [
            From    => 'sri@oook.de',
            To      => 'sri@cpan.org',
            Subject => 'Hello!'
        ],
        body => 'Hello sri'
    );

=head1 DESCRIPTION

Send emails with Catalyst and L<Email::Send> and L<Email::MIME::Creator>.

=head2 METHODS

=head3 email

=cut

sub email {
    my $c = shift;
    my $email = $_[1] ? {@_} : $_[0];
    $email = Email::MIME->create(%$email);
    my $args = $c->config->{email} || [];
    my @args = @{$args};
    my $class;
    unless ( $class = shift @args ) {
        $class = 'SMTP';
        unshift @args, 'localhost';
    }
    send $class => $email, @args;
}

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

1;
