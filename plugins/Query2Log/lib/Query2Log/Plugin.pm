package Query2Log::Plugin;
use strict;

sub _post_run {
    my $app = MT->instance;
    if ( (ref $app) !~ /^MT::App::/ ) {
        return;
    }
    if ( my $level = MT->config( 'Query2LogDebugMode' ) ) {
        if ( $level == 1 && ( $app->request_method eq 'GET'
            || $app->mode eq 'filtered_list' ) ) {
            return;
        }
        $app->log( {
                message => MT->instance->query_string,
                level => 4,
        } );
    }
}

sub _hdlr_query2log {
    my ( $ctx, $args, $cond ) = @_;
    my $message = $args->{ message } or '';
    if ( $message ) {
        $message .= ' : ';
    }
    my $app = MT->instance;
    if ( (ref $app) !~ /^MT::App::/ ) {
        return '';
    }
    my $q = $app->query_string;
    if ( $args->{ url } ) {
        my $sep = '';
        if ( $q ) {
            $sep = '?';
        }
        $q = $app->base . $app->path . $app->script . $sep . $q;
    }
    $message .= $q;
    $app->log( {
            message => $message,
            level => 4,
    } );
    if ( $args->{ print } ) {
        return $message;
    }
    return '';
}

1;