import consumer from "./consumer"

consumer.subscriptions.create({channel: "NotificationsChannel"}, {
  connected() {
    console.log("Connected to the Notifications channel");
  },

  disconnected() {
    console.log("Disconnected from the Notifications channel");
  },

  received(data) {
    console.log("Received data:", data);
    alert(data.message);
  }
});
