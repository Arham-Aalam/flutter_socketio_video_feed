
const server = require('http').createServer();
const io = require('socket.io')(server, {
  path: '/',
  pingInterval: 10000,
  pingTimeout: 5000,
});

io.on('connection', client => {
    console.log("==> connection established!!");
  client.on('image_info', data => { 
      console.log('got data => ', data);
      client.emit('image_info', {"data": "I got the data!!!!"});
   });
  client.on('disconnect', () => { /* … */ });
});

server.listen(3000);
console.log('listening to localhost:3000');