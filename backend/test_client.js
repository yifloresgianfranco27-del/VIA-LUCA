const { io } = require("socket.io-client");

const socket = io("http://localhost:3000");

socket.on("connect", () => {
  console.log("Simulador de taxi VIA LUCA conectado:", socket.id);

  setInterval(() => {
    const coords = { lat: -12.046374, lng: -77.042793 };
    console.log("Enviando GPS...", coords);
    socket.emit("actualizar_ubicacion", coords);
  }, 3000);
});
