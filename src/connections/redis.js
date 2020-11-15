const { promisify } = require("util");
const redis = require("redis");
const configs = require("../constants/configs");
const wsClients = require("../constants/ws_clients");

const CHANNEL = "COMMUNICATION";

const client = redis.createClient({ url: configs.REDIS_URL, db: 2 });
const subscriber = redis.createClient({ url: configs.REDIS_URL, db: 2 });

const get = promisify(client.get).bind(client);
const set = promisify(client.set).bind(client);
const del = promisify(client.del).bind(client);

client.on("error", (err) => {
  console.log(`Redis.on error Error ${err}`);
});

(() => {
  if (configs.TEST)
    client.flushdb((err, success) => {
      if (err) console.log(`client.flushdb Error ${err}`);
      if (success) console.log(`client.flushdb Success ${success}`);
    });
})();

subscriber.on("message", function subscribe(channel, message) {
  console.log(`${message} receive from ${channel} channel.`);
  const { id, type, data } = JSON.parse(message);
  if (!wsClients[id.toString()]) return;
  wsClients[id.toString()].send(JSON.stringify({ type, data }));
});

function publish(id, type, data) {
  client.publish(CHANNEL, JSON.stringify({ type, id, data }));
}
module.exports = {
  get,
  set,
  del,
  publish,
};
