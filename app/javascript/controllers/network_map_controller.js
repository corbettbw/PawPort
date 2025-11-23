// app/javascript/controllers/network_map_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    shelters: Array
  }

  connect() {
    if (!window.L) {
      console.warn("Leaflet (L) not available")
      return
    }

    const shelters = this.sheltersValue || []
    if (shelters.length === 0) return

    // Use first shelter as a fallback center
    const firstWithCoords = shelters.find(s => s.latitude && s.longitude) || shelters[0]

    this.map = L.map(this.element).setView(
      [firstWithCoords.latitude || 0, firstWithCoords.longitude || 0],
      10
    )

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 18,
      attribution: "&copy; OpenStreetMap contributors"
    }).addTo(this.map)

    const markers = []

    shelters.forEach(shelter => {
      if (!shelter.latitude || !shelter.longitude) return

      const { color, label } = this.markerStyleFor(shelter)

      const icon = L.divIcon({
        className: "",
        html: `
          <div style="
            background:${color};
            border-radius:9999px;
            padding:6px 8px;
            min-width:24px;
            text-align:center;
            color:#fff;
            font-size:12px;
            font-weight:600;
            box-shadow:0 4px 10px rgba(15,23,42,0.25);
            border:2px solid rgba(15,23,42,0.3);
          ">
            ${label}
          </div>
        `,
        iconAnchor: [12, 12]
      })

      const marker = L.marker([shelter.latitude, shelter.longitude], { icon }).addTo(this.map)

      marker.bindPopup(`
        <strong>${this.escapeHtml(shelter.name || "Shelter")}</strong><br/>
        ${this.escapeHtml(shelter.address || "")}<br/>
        Vacancies: ${shelter.vacancies ?? 0} / ${shelter.capacity ?? 0}
      `)

      markers.push(marker)
    })

    if (markers.length > 0) {
      const group = L.featureGroup(markers)
      this.map.fitBounds(group.getBounds().pad(0.2))
    }
  }

  markerStyleFor(shelter) {
    const capacity = shelter.capacity || 0
    const vacancies = shelter.vacancies || 0

    if (capacity <= 0) {
      return { color: "#6b7280", label: "?" } // grey unknown
    }

    const ratio = vacancies / capacity

    if (vacancies === 0) {
      // Red, no text
      return { color: "#ef4444", label: "" }
    } else if (ratio < 0.5) {
      // Yellow, show number
      return { color: "#facc15", label: vacancies.toString() }
    } else {
      // Green, show number
      return { color: "#22c55e", label: vacancies.toString() }
    }
  }

  escapeHtml(str) {
    if (!str) return ""
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }
}
