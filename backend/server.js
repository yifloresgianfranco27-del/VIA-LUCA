const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

app.use(express.json());

app.get('/', (req, res) => {
  res.send('Servidor de VIA LUCA activo');
});

io.on('connection', (socket) => {
  console.log('Usuario o Conductor conectado:', socket.id);

  socket.on('actualizar_ubicacion', (coords) => {
    io.emit('ubicacion_conductor', coords);
  });
});

server.listen(3000, () => {
  console.log('Backend de VIA LUCA corriendo en puerto 3000');
});
