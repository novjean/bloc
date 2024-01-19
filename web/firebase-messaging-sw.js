importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAD0sTtm4IHDYRk61evjU7rDz8DTXDqjp4",
  authDomain: "bloc-novatech.firebaseapp.com",
  projectId: "bloc-novatech",
  storageBucket: "bloc-novatech.appspot.com",
  messagingSenderId: "328003399661",
  appId: "1:328003399661:web:fc4cec734ef80b804781e4",
  measurementId: "G-9LBTH88DZP"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Retrieve firebase messaging
const messaging = firebase.messaging();
//const analytics = getAnalytics(app);

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("Received background message ", payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});