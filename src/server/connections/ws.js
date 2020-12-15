const WebSocket = require("ws");
const jwt = require("../utilities/jwt");
const redis = require("./redis");
const configs = require("../constants/configs");
const wsClients = require("../constants/ws_clients");
const { AUTHORIZATION } = require("../constants/ws_types");

/**
 * Websocket introduction type handler
 *
 * @param {String} message
 * @param {WebSocket} ws
 */
async function introductionHandler(message, ws) {
  if (message.type === AUTHORIZATION) {
    if (configs.BYPASS_MIDDLEWARE) {
      wsClients[message.data.id.toString()] = ws;
      ws.send(
        JSON.stringify({
          type: "AUTHORIZATION",
          data: { message: "Verified User" },
        })
      );
      const reply = await redis.get(`${redis.CHANNEL}-${message.data.id}`);
      if (reply != null) {
        ws.send(reply);
        redis.del(`${redis.CHANNEL}-${message.data.id}`);
      }
      return message.data.id.toString();
    }
    const { token } = message.data;
    const decoded = await jwt.verify(token, configs.JWT_SECRET);
    let reply = await redis.get(`token-${decoded.id}`);
    if (reply) {
      wsClients[message.data.id.toString()] = ws;
      ws.send(
        JSON.stringify({
          type: "AUTHORIZATION",
          data: { message: "Verified User" },
        })
      );
      reply = await redis.get(`${redis.CHANNEL}-${decoded.id}`);
      if (reply != null) {
        ws.send(reply);
        redis.del(`${redis.CHANNEL}-${decoded.id}`);
      }
    } else {
      throw Error("Jwt token isn't store in redis.");
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
      console.log("ws message : ", data.toString());
      try {
        const message = JSON.parse(data.toString());
        userId = await introductionHandler(message, ws);
      } catch (err) {
        console.log(`ws.on message Error ${err}`);
        ws.send(
          JSON.stringify({
            type: "UNAUTHORIZATION",
            data: { message: "Unverified User" },
          })
        );
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
