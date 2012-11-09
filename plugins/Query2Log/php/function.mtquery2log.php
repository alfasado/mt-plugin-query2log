<?php
function smarty_function_mtquery2log ( $args, &$ctx ) {
    $app = $ctx->stash( bootstrapper );
    $message = $args[ 'message' ];
    if ( $message ) {
        $message .= ' : ';
    }
    $q = $app->query_string;
    if ( $args[ 'url' ] ) {
        if ( $q ) $sep = '?';
        $q = $app->base . $app->path . $app->script . $sep . $q;
    }
    $message .= $q;
    $params = array();
    $params[ 'level' ] = 4;
    $app->log( $message, $params );
    if ( $args[ 'print' ] ) {
        return $message;
    }
    return '';
}
?>