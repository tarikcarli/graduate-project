const redis = require("redis");
const { promisify } = require("util");
const configs = require("../constants/configs");

const client = redis.createClient();

const get = promisify(client.get).bind(client);
const set = promisify(client.set).bind(client);
const del = promisify(client.del).bind(client);

client.on("error", (err) => {
  console.log(`Redis.on.error Error ${err}`);
});

(() => {
  if (configs.test)
    client.flushdb((err, success) => {
      if (err) console.log(`client.flushdb Error ${err}`);
      if (success) console.log(`client.flushdb Success ${success}`);
    });
})();

exports.get = get;
exports.set = set;
exports.del = del;
