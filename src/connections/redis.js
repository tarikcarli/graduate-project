const redis = require("redis");
const { promisify } = require("util");
const client = redis.createClient();

const get = promisify(client.get).bind(client);
const set = promisify(client.set).bind(client);
const del = promisify(client.del).bind(client);

client.on("error", (err) => {
  console.log(`Redis.on.error Error ${err}`);
});

exports.get = get;
exports.set = set;
exports.del = del;
