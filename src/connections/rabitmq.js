const amqp = require("amqplib/callback_api");

amqp.connect("amqp://localhost", (err, conn) => {
  if (err) {
    console.log(`amqp.connect Error ${err}`);
    return;
  }
  conn.createChannel((err, ch) => {
    if (err) {
      console.log(`conn.createChannel Error ${err}`);
      return;
    }
    const queue = "helloWorl";
    const msg = "Hello World";
    ch.assertQueue(queue, { durable: false });
    ch.consume(queue, (msg) => {
      console.log(`[x] Received ${msg.content.toString()}`);
    });
    ch.sendToQueue(queue, Buffer.from(msg));
    console.log(` [x] Sent ${msg}`);
  });
});
