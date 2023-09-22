const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

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
          title: '📝 guest : '+snapshot.data().name+' '+snapshot.data().surname,
          body: snapshot.data().guestStatus+' - '+snapshot.data().guestsCount,
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
          title: '🛎️ reservation : ' + snapshot.data().name,
          body: snapshot.data().occasion + ' - ' + snapshot.data().guestsCount,
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
          title: '🎊 celebration : ' + snapshot.data().name,
          body: snapshot.data().occasion+' - '+snapshot.data().guestsCount,
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
        data: {
          type: 'notification_tests',
          document: JSON.stringify(snapshot.data()),
        },
      });
    });