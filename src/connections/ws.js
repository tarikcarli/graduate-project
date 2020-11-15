const WebSocket = require("ws");
const jwt = require("../utilities/jwt");
const redis = require("./redis");
const configs = require("../constants/configs");
const wsClients = require("../constants/ws_clients");
const { INTRODUCTION } = require("../constants/ws_types");

/**
 * Websocket introduction type handler
 *
 * @param {String} message
 * @param {WebSocket} ws
 */
async function introductionHandler(message, ws) {
  if (message.type === INTRODUCTION) {
    if (configs.BYPASS_MIDDLEWARE) {
      wsClients[message.data.id.toString()] = ws;
      return message.data.id.toString();
    }
    const { token } = message.data;
    const decoded = await jwt.verify(token, configs.JWT_SECRET);
    const reply = await redis.get(`token-${decoded.id}`);
    if (reply) {
      wsClients[message.data.id.toString()] = ws;
    } else {
      throw new Error("Jwt token isn't store in redis.");
    }
    return decoded.id.toString();
  }
  return null;
}

/**
 * Create websocket server over existing http server
 *
 * @param {Object} server
 */
const init = (server) => {
  const wss = new WebSocket.Server({ server });

  wss.on("connection", (ws) => {
    let userId;
    ws.on("message", async (data) => {
      try {
        const message = JSON.parse(data.toString());
        userId = await introductionHandler(message, ws);
      } catch (err) {
        console.log(`ws.on message Error ${err}`);
        ws.close();
      }
    });

    ws.on("close", () => {
      const result = delete wsClients[userId];
      console.log(`ws close event ${userId} ${result}`);
      ws.close();
    });
  });
};

exports.init = init;
