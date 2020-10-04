const { clients } = require("./ws");
const redis = require("./redis");
const { env } = require("../config/env");
const amqp = require("amqplib/callback_api");
const rabbitmq = {};
const exchange = "NOTIFICATION7";

amqp.connect(env.rabbitmqUrl, (err, conn) => {
  if (err) {
    console.log(`amqp.connect Error ${err}`);
    return;
  }
  conn.createChannel((err, ch) => {
    if (err) {
      console.log(`conn.createChannel Error ${err}`);
      return;
    }
    ch.assertExchange(exchange, "direct", {
      durable: true,
    });
    ch.assertQueue("", { exclusive: true }, (err, q) => {
      if (err) {
        console.log(`ch.assertQueue Error ${err}`);
        return;
      }
      ch.prefetch(1);
      ch.consume(
        q.queue,
        async (msg) => {
          console.log(
            ` [x] ${msg.fields.routingKey}: ${msg.content.toString()}`
          );
          ch.ack(msg);
          redis.del(`not${msg.fields.routingKey}`);
        },
        { noAck: false }
      );

      rabbitmq.bind = ((ch, q, exchange) => (userId) => {
        ch.bindQueue(q.queue, exchange, userId, null, async (err, result) => {
          if (err) {
            console.log(`ch.bindQueue Error ${err}`);
            return;
          }
          const reply = await redis.get(`not${userId}`);
          if (reply) rabbitmq.publish(userId, reply);
        });
      })(ch, q, exchange);

      rabbitmq.unbind = ((ch, q, exchange) => (userId) => {
        ch.unbindQueue(q.queue, exchange, userId, null, async (err, result) => {
          if (err) {
            console.log(`ch.unbindQueue Error ${err}`);
            return;
          }
        });
      })(ch, q, exchange);
      // rabbitmq.bind("1");
      // rabbitmq.bind("2");
      // rabbitmq.bind("3");
    });
    rabbitmq.publish = ((ch, exchange) => async (userId, msg) => {
      await redis.set(`not${userId}`, msg);
      ch.publish(exchange, userId, Buffer.from(msg), {
        persistent: true,
      });
      console.log(` [x] Sent ${msg} to ${exchange}: ${userId}`);
    })(ch, exchange);
    // rabbitmq.publish("1", "tarik carli");
    // rabbitmq.publish("2", "tarik carli");
    // rabbitmq.publish("3", "tarik carli");
  });
});
module.exports = rabbitmq;
