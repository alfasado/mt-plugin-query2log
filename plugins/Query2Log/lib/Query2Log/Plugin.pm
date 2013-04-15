package Query2Log::Plugin;
use strict;

use MT::Log;

sub _post_run {
    my $app = MT->instance;
    if ( ( ref $app ) !~ /^MT::App::/ ) {
        return;
    }
    if ( my $level = MT->config( 'Query2LogDebugMode' ) ) {
        if ( $level == 1 && ( $app->request_method eq 'GET'
            || $app->mode eq 'filtered_list' ) ) {
            return;
        }
        $app->log( {
                message => MT->instance->query_string,
                catgory => 'query2log',
                level => MT::Log::DEBUG(),
        } );
    }
}

sub _error {
    my ( $cb, $app, $param, $tmpl ) = @_;
    if ( MT->config( 'Query2LogAtError' ) ) {
        $app->log( {
                message => $param->{ error } .
                ' : ' . MT->instance->query_string,
                catgory => 'query2log',
                level => MT::Log::ERROR(),
        } );
    }
}

sub _error_log {
    my ( $cb, $obj ) = @_;
    my $app = MT->instance;
    if ( ( ref $app ) !~ /^MT::App::/ ) {
        return 1;
    }
    return 1 if $obj->level != MT::Log::ERROR();
    return 1 if $obj->category eq 'query2log';
    if ( MT->config( 'Query2LogAtError' ) ) {
        $app->log( {
                message => $obj->message .
                ' : ' . $app->query_string,
                catgory => 'query2log',
                level => MT::Log::ERROR(),
        } );
    }
    return 1;
}

sub _hdlr_query2log {
    my ( $ctx, $args, $cond ) = @_;
    my $message = $args->{ message } || '';
    if ( $message ) {
        $message .= ' : ';
    }
    my $app = MT->instance;
    if ( ( ref $app ) !~ /^MT::App::/ ) {
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
            catgory => 'query2log',
            level => MT::Log::DEBUG(),
    } );
    if ( $args->{ print } ) {
        return $message;
    }
    return '';
}

1;