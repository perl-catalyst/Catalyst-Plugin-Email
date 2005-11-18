package Catalyst::Plugin::Email;

use strict;
use Email::Send;
use Email::MIME;
use Email::MIME::Creator;

our $VERSION = '0.05';

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

=head1 USING WITH A VIEW

A common practice is to handle emails using the same template language used
for HTML pages.  This can be accomplished by pairing this plugin with
L<Catalyst::Plugin::SubRequest>.

Here is a short example of rendering an email from a Template Toolkit source
file.  The call to $c->subreq makes an internal call to the render_email
method just like an external call from a browser.  The request will pass
through the end method to be processed by your View class.

    sub send_email : Local {
        my ( $self, $c ) = @_;  

        $c->email(
            header => [
                To      => 'me@localhost',
                Subject => 'A TT Email',
            ],
            body => $c->subreq( '/render_email' ),
        );
        # redirect or display a message
    }
    
    sub render_email : Local {
        my ( $self, $c ) = @_;
        
        $c->stash(
            names    => [ qw/andyg sri mst/ ],
            template => 'email.tt',
        );
    }
    
And the template:

    [%- FOREACH name IN names -%]
    Hi, [% name %]!
    [%- END -%]
    
    --
    Regards,
    Us

Output:

    Hi, andyg!
    Hi, sri!
    Hi, mst!
    
    --
    Regards,
    Us

=head1 METHODS

=head2 email

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

L<Catalyst>, L<Catalyst::Plugin::SubRequest>, L<Email::Send>,
L<Email::MIME::Creator>

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

1;
