window.makePeerHeartbeater = function(peer) {
    var timeoutId = 0;
    function heartbeat () {
        timeoutId = setTimeout( heartbeat, 20000 );
        if ( peer.socket._wsOpen() ) {
            console.log("sending heartbeart")
            peer.socket.send( {type:'HEARTBEAT'} );
        }
    }
    // Start
    heartbeat();
    // return
    return {
        start : function () {
            if ( timeoutId === 0 ) { heartbeat(); }
        },
        stop : function () {
            clearTimeout( timeoutId );
            timeoutId = 0;
        }
    };
}
