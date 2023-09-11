const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.loungeChatFunction = functions
    .region('asia-south1')
    .firestore
    .document('lounge_chats/{message}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('lounge_chats', {
        notification: {
          title: snapshot.data().userName,
          body: snapshot.data().message,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          type: 'lounge_chats',
          document: JSON.stringify(snapshot.data()),
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
          title: 'help : table ' + snapshot.data().tableNumber.toString(),
          body: snapshot.data().name,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      });
    });

exports.orderFunction = functions
    .region('asia-south1')
    .firestore
    .document('orders/{order}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('order', {
        notification: {
          title: 'order : table ' + snapshot.data().tableNumber.toString(),
          body: 'order has been received!',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      });
    });

exports.offerFunction = functions
    .region('asia-south1')
    .firestore
    .document('offers/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('offer', {
        notification: {
          title: 'offer : ' + snapshot.data().productName + '!',
          body: 'grab one now!',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      });
    });

exports.adFunction = functions
    .region('asia-south1')
    .firestore
    .document('ads/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('ads', {
        notification: {
          title: snapshot.data().title,
          body: snapshot.data().message,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          type: 'ads',
          document: JSON.stringify(snapshot.data()),
        },
      });
    });

exports.partyGuestFunction = functions
    .region('asia-south1')
    .firestore
    .document('party_guests/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('party_guest', {
        notification: {
          title: 'request : guest list',
          body: snapshot.data().name + ' ' + snapshot.data().surname,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          type: 'party_guest',
          document: JSON.stringify(snapshot.data()),
        },
      });
    });

exports.reservationFunction = functions
    .region('asia-south1')
    .firestore
    .document('reservations/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('reservations', {
        notification: {
          title: 'request : table reservation',
          body: snapshot.data().name + ' - ' + snapshot.data().guestsCount,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          type: 'reservations',
          document: JSON.stringify(snapshot.data()),
        },
      });
    });

exports.celebrationFunction = functions
    .region('asia-south1')
    .firestore
    .document('celebrations/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('celebrations', {
        notification: {
          title: 'request : celebration',
          body: snapshot.data().name + ' - ' + snapshot.data().guestsCount,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          type: 'celebrations',
          document: JSON.stringify(snapshot.data()),
        },
      });
    });

exports.notificationTestFunction = functions
    .region('asia-south1')
    .firestore
    .document('notification_tests/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      return admin.messaging().sendToTopic('notification_tests', {
//        notification: {
//          title: 'notification test',
//          body: snapshot.data().text,
//          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
//        },
        data: {
          type: 'notification_tests',
          document: JSON.stringify(snapshot.data()),
        },
      });
    });

//exports.silentNotificationTestFunction = functions
//    .region('asia-south1')
//    .firestore
//    .document('notification_tests/{document}')
//    .onCreate((snapshot, context) => {
//      console.log(snapshot.data());
//      // Define the message payload (custom data)
//      const message = {
//        data: {
//          type: 'notification_tests',
//          document: JSON.stringify(snapshot.data()),
//        },
//        topic: 'notification_tests',
//      };
//
//      return admin.messaging().send(message)
//          .then((response) => {
//            console.log('message sent successfully:', response);
//          })
//          .catch((error) => {
//            console.error('error sending message:', error);
//          });
//    });