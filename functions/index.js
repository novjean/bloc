const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.chatFunction = functions
    .region('asia-south1')
    .firestore
    .document('chats/{message}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('chat', {
        notification: {
          title: snapshot.data().username,
          body: snapshot.data().text,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      });
    });

exports.sosFunction = functions
    .region('asia-south1')
    .firestore
    .document('sos/{help}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('sos', {
        notification: {
          title: 'SOS : Table ' + snapshot.data().tableNumber.toString(),
          body: snapshot.data().name,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      });
    });

//exports.offersFunction = functions
//    .region('asia-south1')
//    .firestore
//    .document('offers/{document}')
//    .onCreate((snapshot, context) => {
//      console.log(snapshot.data());
//      return admin.messaging().sendToTopic('offer', {
//        notification: {
//          title: 'Offer : Something ' + snapshot.data().tableNumber.toString(),
//          body: snapshot.data().name,
//          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
//        },
//      });
//    });