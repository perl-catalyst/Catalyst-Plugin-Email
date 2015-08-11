use strict;
use warnings;

use ExtUtils::MakeMaker;

my $developer = -f '.gitignore';
ExtUtils::MakeMaker->VERSION('7.00') if $developer;

my %WriteMakefileArgs = (
    NAME => 'Catalyst::Plugin::Email',
    VERSION_FROM => 'lib/Catalyst/Plugin/Email.pm',
    ABSTRACT => 'Send emails with Catalyst',
    AUTHOR => 'Sebastian Riedel <sri@cpan.org>',
    LICENSE => 'perl_5',
    MIN_PERL_VERSION => 5.008,  # catalyst minimum
    PREREQ_PM => {
        'Catalyst'              => '2.99',
        'Email::Send'           => '0',
        'Email::MIME'           => '0',
        'Email::MIME::Creator'  => '0',
    },
    TEST_REQUIRES => {
    },
);

die 'need to do a merge with CPAN::Meta::Requirements!!'
    if $developer && exists $WriteMakefileArgs{BUILD_REQUIRES};

if (!eval { ExtUtils::MakeMaker->VERSION('6.6303') }) {
    $WriteMakefileArgs{BUILD_REQUIRES} = $WriteMakefileArgs{TEST_REQUIRES};
    delete $WriteMakefileArgs{TEST_REQUIRES};
}

if (!eval { ExtUtils::MakeMaker->VERSION('6.5501') }) {
    @{$WriteMakefileArgs{PREREQ_PM}}{ keys %{$WriteMakefileArgs{BUILD_REQUIRES}} } =
        @{$WriteMakefileArgs{BUILD_REQUIRES}}{ keys %{$WriteMakefileArgs{BUILD_REQUIRES}} };

    delete $WriteMakefileArgs{BUILD_REQUIRES};
}

my %mm_req = (
    LICENCE => 6.31,
    META_MERGE => 6.45,
    META_ADD => 6.45,
    MIN_PERL_VERSION => 6.48,
);
for (keys %mm_req) {
    unless (eval { ExtUtils::MakeMaker->VERSION($mm_req{$_}) }) {
        warn "$_ $@" if $developer;
        delete $WriteMakefileArgs{$_};
    }
}

WriteMakefile(%WriteMakefileArgs);
