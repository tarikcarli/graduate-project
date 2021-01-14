const fs = require('fs');
const nodemailer = require("nodemailer");

class EmailService {
  static transporter;

  static create({
    service = "Gmail",
    user = "starikcarli@gmail.com",
    pass = "rrptbeud2d"
  } = {}
  ){
    this.transporter = nodemailer.createTransport({
      service,
      auth: {
        user,
        pass,
      }
    });
  }

  static send({
    from = "starikcarli@gmail.com", 
    to = "pro.tarikcarli@gmail.com", 
    userName,
    taskName,
    duration,
    distance,
    isValid,
    isAccepted,
    date,
    imageName
  } = {}
  ){
    const mailOptions = {
      from,
      to,
      subject: `${userName} Çalışanının Fatura Detayı`,
      html: `
<h1>Fatura Detayı</h1>
<p><span style="font-weight: bold;">Çalışan ismi:</span> ${userName}.</p>
<p><span style="font-weight: bold;">Görev ismi:</span> ${taskName}.</p>
<p><span style="font-weight: bold;">Seyahat süresi:</span> ${duration} dakika.</p>
<p><span style="font-weight: bold;">Seyahat mesafesi:</span> ${distance} kilometre.</p>
<p><span style="font-weight: bold;">Geçerlilik durumu:</span> ${isValid?"geçerli":"geçerli değil"}.</p>
<p><span style="font-weight: bold;">Kabul durumu:</span> ${isAccepted?"kabul edildi":"reddedildi"}.</p>
<p><span style="font-weight: bold;">Fatura Tarihi:</span> ${date.toLocaleDateString()} ${date.toLocaleTimeString()}.</p>
      `,
      attachments: [{   // stream as an attachment
        filename: `${taskName}_fatura.jpg`,
        content: fs.createReadStream(`${process.cwd()}/public/images/${imageName}`)
    }]
    }
    console.log(`Before send, mail options: ${mailOptions}`);
    return new Promise((resolve,reject) => {
      this.transporter.sendMail(mailOptions, (error, info) => {
        if(error){
          console.log(`Error email sent: ${error}`);
          reject(error);
          return;
        } else {
          console.log(`Success email sent: ${info.response}`);
          resolve();
          return;
        }
      })
    });

  }
}

module.exports = EmailService;