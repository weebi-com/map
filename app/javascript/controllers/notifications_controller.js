import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.channel = this.createChannel()
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }

  createChannel() {
    return consumer.subscriptions.create("NotificationsChannel", {
      received: (data) => this.showNotification(data.message)
    })
  }

  showNotification(message) {
    const notification = document.createElement('div')
    notification.className = 'alert alert-success'
    notification.innerText = message
    document.body.appendChild(notification)

    setTimeout(() => {
      notification.remove()
    }, 5000)
  }
}
