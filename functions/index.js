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
      const message = {
        notification: {
          title: snapshot.data().title,
          body: snapshot.data().message,
          image: snapshot.data().imageUrl,
        },
        android: {
          notification: {
            sound: 'default',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: {
            aps: {
              'mutable-content': 1,
            },
          },
          fcm_options: {
            image: snapshot.data().imageUrl,
          },
        },
        data: {
          type: 'ads',
          document: JSON.stringify(snapshot.data()),
        },
        topic: 'ads',
      };

      return admin.messaging().send(message)
          .then((response) => {
            console.log('Successfully sent ad message:', response);
          })
          .catch((error) => {
            console.log('Error sending ad message:', error);
          });
    });

exports.chatFunction = functions
    .region('asia-south1')
    .firestore
    .document('lounge_chats/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      const message = {
        notification: {
          title: '🗨️ ' + snapshot.data().loungeName,
          body: snapshot.data().userName + ': '+snapshot.data().message,
          image: snapshot.data().imageUrl,
        },
        android: {
          notification: {
            sound: 'default',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: {
            aps: {
              'mutable-content': 1,
            },
          },
          fcm_options: {
            image: snapshot.data().imageUrl,
          },
        },
        data: {
          type: 'lounge_chats',
          document: JSON.stringify(snapshot.data()),
        },
        topic: snapshot.data().loungeId,
      };

      return admin.messaging().send(message)
          .then((response) => {
            console.log('Successfully sent chat:', response);
          })
          .catch((error) => {
            console.log('Error sending chat:', error);
          });
    });

exports.friendNotificationFunction = functions
    .region('asia-south1')
    .firestore
    .document('friend_notifications/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      const message = {
        notification: {
          title: snapshot.data().title,
          body: snapshot.data().message,
          image: snapshot.data().imageUrl,
        },
        android: {
          notification: {
            sound: 'default',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: {
            aps: {
              'mutable-content': 1,
            },
          },
          fcm_options: {
            image: snapshot.data().imageUrl,
          },
        },
        data: {
          type: 'friend_notifications',
          document: JSON.stringify(snapshot.data()),
        },
        topic: snapshot.data().topic,
      };

      return admin.messaging().send(message)
          .then((response) => {
            console.log('Successfully notified friend:', response);
          })
          .catch((error) => {
            console.log('Error notifying friend:', error);
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

exports.partyGuestFunction = functions
    .region('asia-south1')
    .firestore
    .document('party_guests/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());

      if (snapshot.data().guestStatus !== 'promoter') {
        console.log('party guest status is ' + snapshot.data().guestStatus);

        return admin.messaging().sendToTopic('party_guest', {
          notification: {
            title: '📝 guest : ' + snapshot.data().name + ' ' +
              snapshot.data().surname,
            body: snapshot.data().guestStatus + ' - ' +
               snapshot.data().guestsCount,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
          data: {
            type: 'party_guest',
            document: JSON.stringify(snapshot.data()),
          },
        });
      } else {
        console.log('party guest no show as ' + snapshot.data().guestStatus);

        return admin.messaging().sendToTopic('party_guest', {
          data: {
            type: 'party_guest',
            document: JSON.stringify(snapshot.data()),
          },
        });
      }
    });

exports.tixFunction = functions
    .region('asia-south1')
    .firestore
    .document('tixs/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());

      if (!snapshot.data().isConfirmed) {
        return admin.messaging().sendToTopic('tixs', {
          notification: {
            title: '🎫 tix : ' + snapshot.data().userName,
            body: 'a ticket has been purchased for ' + snapshot.data().total,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
          data: {
            type: 'tixs',
            document: JSON.stringify(snapshot.data()),
          },
        });
      }
    });

exports.userPhotoFunction = functions
    .region('asia-south1')
    .firestore
    .document('user_photos/{document}')
    .onCreate((snapshot, context) => {
      console.log('new user photo doc ' + snapshot.data().id);

      if (!snapshot.data().isConfirmed) {
        return admin.messaging().sendToTopic('user_photos', {
          notification: {
            title: '📷 request : photo tag',
            body: 'a request has been received.',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
          data: {
            type: 'user_photos',
            document: JSON.stringify(snapshot.data()),
          },
        });
      }
    });

exports.notificationTestFunction = functions
    .region('asia-south1')
    .firestore
    .document('notification_tests/{document}')
    .onCreate((snapshot, context) => {
      console.log(snapshot.data());
      const message = {
        notification: {
          title: '️🗿 test title: ' + snapshot.data().title,
          body: 'test body: ' + snapshot.data().body,
          image: snapshot.data().imageUrl,
        },
        data: {
          type: 'notification_tests_2',
          document: JSON.stringify(snapshot.data()),
        },
        apns: {
          payload: {
            aps: {
              'mutable-content': 1,
            },
          },
          fcm_options: {
            image: snapshot.data().imageUrl,
          },
        },
        topic: 'notification_tests_2',
      };

      return admin.messaging().send(message)
          .then((response) => {
          // Response is a message ID string.
            console.log('Successfully sent test notify message:', response);
          })
          .catch((error) => {
            console.log('Error sending test notify message:', error);
          });
    });