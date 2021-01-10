const { promisify } = require("util");
const redis = require("redis");
const configs = require("../constants/configs");
const wsClients = require("../constants/ws_clients");
// const wsTypes = require("../constants/ws_types");

const CHANNEL = "COMMUNICATION";

const client = redis.createClient({ url: configs.REDIS_URL});
const subscriber = redis.createClient({ url: configs.REDIS_URL});

const get = promisify(client.get).bind(client);
const set = promisify(client.set).bind(client);
const del = promisify(client.del).bind(client);

client.on("error", (err) => {
  console.log(`Redis.on error Error ${err}`);
});

(() => {
  if (configs.DEVELOPMENT)
    client.flushdb((err, success) => {
      if (err) console.log(`client.flushdb Error ${err}`);
      if (success) console.log(`client.flushdb Success ${success}`);
    });
})();
subscriber.on("subscribe", function subscribe(channel, count) {
  console.log(`On subscribe ${channel} ${count}`);
});

subscriber.on("message", function getMessage(channel, message) {
  // console.log(`${message} receive from ${channel} channel.`);
  const { id, type, data } = JSON.parse(message);
  if (!wsClients[`${id}`]) return;
  del(`${CHANNEL}-${id}`);
  wsClients[id.toString()].send(JSON.stringify({ type, data }));
});
subscriber.subscribe(CHANNEL);

/**
 *
 *
 * @param {*} id  it is user id that he receives message.
 * @param {*} type it is one of wsTypes strings.
 * @param {*} data it is websocket message body.
 */
function publish(id, type, data) {
  const message = JSON.stringify({ type, id, data });
  if (type.includes("NOTIFICATION")) set(`${CHANNEL}-${id}`, message);
  client.publish(CHANNEL, message);
}
module.exports = {
  get,
  set,
  del,
  publish,
  CHANNEL,
};
