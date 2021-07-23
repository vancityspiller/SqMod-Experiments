const cp = require('child_process');

// it is actually possible to stop and start your server from discord (or elsewhere)
// to stop: just use 'SqServer.Shutdown()' when you receive shutdown command (or execute a kill through cp.exec)
// to start:

const server = cp.spawn('./mpsvrrel64', {
    
    // keep running the server even after node exits
    detached: true,
    // do not track io of the spawned process
    stdio: 'ignore'
});

//  prevent waiting for the spawned process to exit
server.unref();

// **** might need to wrap the logic in a setTimeout block if you want to restart your server
//      so that it doesn't start another process before the previous one has shutted down