
const server = require('http').createServer();
const io = require('socket.io')(server);

io.on('rec_frame', client => {
    console.log("==>", client);
  client.on('event', data => { /* … */ });
  client.on('disconnect', () => { /* … */ });
  io.emit('rec_frame', {"data": "I got the data!!!!"})
});

server.listen(3000);
console.log('listening to localhost:3000');