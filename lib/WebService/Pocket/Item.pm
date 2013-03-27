use warnings;
package WebService::Pocket::Item;
{
  $WebService::Pocket::Item::VERSION = '0.002';
}
use Data::Dumper;
use Moose;
use Moose::Util::TypeConstraints;
use DateTime;


subtype 'WebService::Pocket::DateTime' => as class_type('DateTime');
subtype 'WebService::Pocket::Tags' => as 'ArrayRef';

coerce 'WebService::Pocket::DateTime' => from 'Num' => via {
    DateTime->from_epoch( epoch => $_ );
};
coerce 'WebService::Pocket::Tags'
    => from 'Str'   => via { $_ ? [ split ',', $_ ] : [] };

has pocket       => ( is => 'ro', isa => 'WebService::Pocket' );
has item_id      => ( is => 'ro' );
has state        => ( is => 'rw', isa => 'Int' );
has tags         => ( is => 'rw',
    isa => 'WebService::Pocket::Tags', coerce => 1 );
has time_added   => ( is => 'ro',
    isa => 'WebService::Pocket::DateTime', coerce => 1 );
has time_updated => ( is => 'ro',
    isa => 'WebService::Pocket::DateTime', coerce => 1 );
has title        => ( is => 'rw' );
has url          => ( is => 'ro' );

around title => sub {
    my ( $orig, $self, $new_title ) = @_;
    return $self->$orig() unless $new_title;

    my $res = $self->pocket->_send({
        update_title => $self->pocket->json->encode({
            $self->item_id => {
                url => $self->url,
                title => $new_title,
            }
        })
    });

    return $self->$orig( $new_title );
};

around tags => sub {
    my ( $orig, $self, $new_tags ) = @_;
    return $self->$orig() unless $new_tags;

    my $res = $self->pocket->_send({
        update_tags => $self->pocket->json->encode({
            $self->item_id => {
                url => $self->url,
                tags => join ',', @$new_tags,
            }
        })
    });

    return $self->$orig( $new_tags );
};

around state => sub {
    my ( $orig, $self, $new_state ) = @_;
    return $self->$orig() unless defined $new_state;

    my $res = $self->pocket->_send({
        read => $self->pocket->json->encode({
            $self->item_id => {
                url => $self->url,
            }
        })
    }) if $new_state == 0;

    return $self->$orig( $new_state );
};

1;


__END__
=pod

=head1 NAME

WebService::Pocket::Item

=head1 VERSION

version 0.002

=head1 DESCRIPTION

L<WebService::Pocket::Item> represents an item in a
L<Pocket|http://getpocket.com/> list.

=head1 ATTRIBUTES

=head2 item_id

The id of this item, generated by the C<Pocket> service.

=head2 state

The read/unread state of the item. A C<state> of 1 means unread, a
C<state> of 0 means read. If this is modified, the status will be changed
on the server.

=head2 tags

A list of tags on this item.  When altered it will update the tags
on the C<Pocket> server.

=head2 time_added

A L<DateTime> object which represents when this item was added.

=head2 time_updated

A L<DateTime> object which represents the last time this item was updated.

=head2 title

The title of this item. When altered, the title on the server will be updated.

=head2 url

The url of this item.

=head1 AUTHOR

William Wolf <throughnothing@gmail.com>

=head1 COPYRIGHT AND LICENSE


William Wolf has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.

=head1 CONTRIBUTORS

=over 4

=item *

Andreas Marienborg <andreas.marienborg@gmail.com>

=item *

ben hengst <notbenh@cpan.org>

=back

=cut
