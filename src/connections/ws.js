const redis = require("./redis");
const jwt = require("jsonwebtoken");
const { env } = require("../config/env");

const clients = {};
const WebSocket = require("ws");
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
        if (message.type == "INTRODUCTION") {
          const token = message.data.token;
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
