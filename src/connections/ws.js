const jwt = require("jsonwebtoken");
const WebSocket = require("ws");
const redis = require("./redis");
const { env } = require("../config/env");
const { INTRODUCTION } = require("../config/ws_types");

const clients = {};

/**
 *
 *
 * @param {Object} server
 */
const init = (server) => {
  const wss = new WebSocket.Server({ server });

  wss.on("connection", (ws) => {
    let userId;
    ws.on("message", (data) => {
      try {
        const message = JSON.parse(data.toString());
        if (message.type === INTRODUCTION) {
          const { token } = message.data;
          jwt.verify(token, env.secret, async (err, decoded) => {
            if (err) {
              ws.close();
              return;
            }
            userId = decoded.id.toString();
            const reply = await redis.get(`token${userId}`);
            if (reply) {
              clients[message.data.userId.toString()] = ws;
            } else {
              ws.close();
            }
          });
        } else {
          ws.close();
        }
      } catch (err) {
        console.log(`ws.on message Error ${err}`);
        ws.close();
      }
    });

    ws.on("close", () => {
      const result = delete clients[userId];
      console.log(`Connection.on close Success ${userId} ${result}`);
      ws.close();
    });
  });
};
exports.init = init;
exports.clients = clients;
