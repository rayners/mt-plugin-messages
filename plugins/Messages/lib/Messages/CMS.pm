
package Messages::CMS;

use strict;
use warnings;

sub init_app {
    my ( $cb, $app ) = @_;

    my $messages = MT->registry('messages');

    # structure:
    #
    # messages:
    #   template:
    #     message_key:
    #       text:
    #       handler:
    #       class:
    #       condition:

    return 1 unless $messages && %$messages;

    foreach my $tmpl ( keys %$messages ) {

        # add the callback
        MT->add_callback( 'MT::App::CMS::template_param.' . $tmpl,
            10, $cb->plugin, sub { _handle_template( $tmpl, @_ ) } );
    }

    return 1;
}

sub template_source_header {
    my ( $cb, $app, $tmpl ) = @_;

    my $old = q{<mt:if name="system_msg">};
    my $new = q{<mt:if name="messages">
<mt:loop name="messages">
<mtapp:statusmsg id="$msg_id" class="$msg_class"><mt:var name="msg_text"></mtapp:statusmsg>
</mt:loop>
</mt:if>};

    $$tmpl =~ s/\Q$old\E/$new$old/;

    return 1;
}

sub _handle_template {
    my ( $tmpl, $cb, $app, $params ) = @_;

    my $messages = MT->registry('messages');
    return 1 unless ( $messages && $messages->{$tmpl} );

    my @message_loop;

    foreach my $k ( keys %{ $messages->{$tmpl} } ) {
        my $msg = $messages->{$tmpl}->{$k};

        my $condition = $msg->{condition} || sub { return $_[0]->param($k) };

        next unless $condition->($app);

        push @message_loop,
          {
            msg_id    => $k,
            msg_class => ( $msg->{class} || 'info' ),
            msg_text  => (
                $msg->{handler}
                ? MT->handler_to_coderef( $msg->{handler} )->($app)
                : $msg->{label}
            )
          };
    }

    $params->{messages} = \@message_loop;

    return 1;
}

1;
