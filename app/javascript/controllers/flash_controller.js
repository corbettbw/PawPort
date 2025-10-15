import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { timeout: Number }

  connect() {
    if (this.hasTimeoutValue && this.timeoutValue > 0) {
      this.timer = setTimeout(() => this.dismissAll(), this.timeoutValue)
    }
  }

  disconnect() { if (this.timer) clearTimeout(this.timer) }

  close(event) {
    const card = event.target.closest("[data-flash-target='item']")
    if (card) this.fadeOut(card)
  }

  dismissAll() { this.itemTargets.forEach((el) => this.fadeOut(el)) }

  fadeOut(el) {
    el.style.transition = "opacity .25s ease, transform .25s ease"
    el.style.opacity = "0"
    el.style.transform = "translateY(-4px)"
    setTimeout(() => el.remove(), 250)
  }
}
