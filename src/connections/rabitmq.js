const amqp = require("amqplib/callback_api");
const { clients } = require("./ws");
const configs = require("../constants/configs");

const rabbitmq = {};
const exchange = "NOTIFICATION";

amqp.connect(configs.rabbitmq.url, (err, conn) => {
  if (err) {
    console.log(`amqp.connect Error ${err}`);
    return;
  }
  conn.createChannel((err, ch) => {
    if (err) {
      console.log(`conn.createChannel Error ${err}`);
      return;
    }
    rabbitmq.bind = ((ch) => (userId) => {
      ch.assertQueue(`user${userId}`, { durable: true }, (err, _q) => {
        if (err) {
          console.log(`ch.assertQueue Error ${err}`);
          return;
        }
        ch.prefetch(1);
        ch.consume(
          `user${userId}`,
          async (msg) => {
            console.log(` [x] ${userId}: ${msg.content.toString()}`);
            ch.ack(msg);
            if (clients[userId]) {
              clients[userId].send(msg.content.toString());
            }
          },
          { noAck: false, consumerTag: `user${userId}` }
        );
      });
    })(ch);

    rabbitmq.unbind = ((ch) => (userId) => {
      ch.cancel(`user${userId}`, (err, _result) => {
        if (err) {
          console.log(`ch.cancel Error ${err}`);
        }
      });
    })(ch);

    rabbitmq.publish = ((ch) => async (userId, msg) => {
      ch.assertQueue(`user${userId}`, { durable: true }, (err, _q) => {
        if (err) {
          console.log(`ch.assertQueue Error ${err}`);
          return;
        }
        const result = ch.sendToQueue(`user${userId}`, Buffer.from(msg), {
          persistent: true,
        });
        console.log(`${result} [x] Sent ${msg} to ${exchange}: ${userId}`);
      });
    })(ch);
  });
});

// setTimeout(() => {
//   rabbitmq.bind("1");
//   rabbitmq.bind("2");
// }, 500);

// setTimeout(() => {
//   rabbitmq.unbind("2");
// }, 750);

// setTimeout(() => {
//   rabbitmq.bind("3");
//   rabbitmq.bind("2");
// }, 3000);

// setTimeout(() => {
//   rabbitmq.publish("1", "tarik carli");
//   rabbitmq.publish("2", "tarik carli");
//   rabbitmq.publish("3", "tarik carli");
// }, 2000);

module.exports = rabbitmq;
