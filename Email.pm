package Catalyst::Plugin::Email;

use strict;
use Email::Send;
use Email::MIME;
use Email::MIME::Creator;
use Carp qw/croak/;

our $VERSION = '0.06';

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

=head1 CONFIGURATION

C<config> accepts the same options as L<Email::Send>.

To send using the system's C<sendmail> program, set C<config> like so:

    __PACKAGE__->config->{email} = ['Sendmail'];

To send using authenticated SMTP:

    __PACKAGE__->config->{email} = [
        'SMTP', 
        'smtp.myhost.com', 
        username => $USERNAME, 
        password => $PASSWORD, 
    ];

For different methods of sending emails, and appropriate C<config> options, 
see L<Email::Send::NNTP>, L<Email::Send::Qmail>, L<Email::Send::SMTP> and 
L<Email::Send::Sendmail>.

=head1 METHODS

=head2 email

C<email()> accepts the same arguments as L<Email::MIME::Creator>'s 
C<create()>.

    $c->email(
        header => [
            To      => 'me@localhost',
            Subject => 'A TT Email',
        ],
        body => $c->view('TT')->render($c, 'email.tt', {
           additional_template_paths => [ $c->config->{root} . '/email_templates'],
           }
        ),
    );

To send a multipart message, include a C<parts> argument containing an 
arrayref of Email::MIME objects.

    my @parts = (
        Email::MIME->create(
            attributes => {
                content_type => 'application/pdf',
                encoding     => 'quoted-printable',
                name         => 'report.pdf',
            },
            body => $FILE_DATA,
        ),
        Email::MIME->create(
            attributes => {
                content_type => 'text/plain',
                disposition  => 'attachment',
                charset      => 'US-ASCII',
            },
            body => $c->view('TT')->render($c, 'email.tt', {
               additional_template_paths => [ $c->config->{root} . '/email_templates'],
               names => [qw/foo bar baz/]
               }
            ),
        ),
    );
    
    $c->email(
        header => [
            To      => 'me@localhost',
            Subject => 'A TT Email',
        ],
        parts => \@parts,
    );

=cut

sub email {
    my $c = shift;
    my $email = $_[1] ? {@_} : $_[0];
    croak "Can't send mail without recipient"
	unless length($email->{To});
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

=head1 USING WITH A VIEW

A common practice is to handle emails using the same template language used
for HTML pages.  This is best accomplished by capturing the output from the
template. For TT this is done using the C<render> method as described in 
L<Catalyst::View:TT/CAPTURING TEMPLATE OUTPUT>.

Here is a short example of rendering an email from a Template Toolkit source
file.  For more information on render (or how to do this with a view other
than TT, consult the docs for your view) 

    sub send_email : Local {
        my ( $self, $c ) = @_;  

        $c->email(
            header => [
                To      => 'me@localhost',
                Subject => 'A TT Email',
            ],
            body => $c->view('TT')->render('email.tt',
             {  additional_template_paths => [ $c->config->{root} . '/email_templates'],
                names => [ qw/andyg sri mst ash/ ],
             } ),
              
        );
        # redirect or display a message
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
    Hi, ash!
    
    --
    Regards,
    Us

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::View::TT>, L<Email::Send>, L<Email::MIME::Creator>

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

=head1 THANKS

Andy Grundman - Additional documentation

Carl Franks - Additional documentation

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

1;
