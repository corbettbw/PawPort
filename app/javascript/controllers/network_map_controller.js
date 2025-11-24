// app/javascript/controllers/network_map_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    shelters: Array,
    homeLatitude: Number,
    homeLongitude: Number
  }

  connect() {
    if (!window.L) {
      console.warn("Leaflet (L) not available")
      return
    }

    const shelters = this.sheltersValue || []
    if (shelters.length === 0) return

    // Always center on the CURRENT shelter when available
    const hasHomeCenter =
      this.hasHomeLatitudeValue && this.hasHomeLongitudeValue

    let initialLat, initialLng

    if (hasHomeCenter) {
      initialLat = this.homeLatitudeValue
      initialLng = this.homeLongitudeValue
    } else {
      // fallback if no home coordinates exist
      const firstWithCoords =
        shelters.find(s => s.latitude && s.longitude) || shelters[0]
      initialLat = firstWithCoords.latitude || 0
      initialLng = firstWithCoords.longitude || 0
    }

    // Initial view ALWAYS uses the home shelter location
    this.map = L.map(this.element).setView([initialLat, initialLng], 12)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 18,
      attribution: "&copy; OpenStreetMap contributors"
    }).addTo(this.map)

    // ---------------------------
    // HOME SHELTER PIN
    // ---------------------------
    if (hasHomeCenter) {
      const homeIcon = L.divIcon({
        className: "",
        html: `
          <div style="
            background:#3b82f6;
            border-radius:9999px;
            width:14px;
            height:14px;
            box-shadow:0 4px 8px rgba(0,0,0,0.25);
            border:2px solid white;
          "></div>
        `,
        iconAnchor: [7, 7]
      })

      const homeMarker = L.marker(
        [this.homeLatitudeValue, this.homeLongitudeValue],
        { icon: homeIcon }
      ).addTo(this.map)

      homeMarker.bindPopup(`
        <strong>Current Shelter</strong><br/>
        This is your shelter.
      `)
    }

    // ---------------------------
    // OTHER SHELTER MARKERS
    // ---------------------------
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

      const marker = L.marker(
        [shelter.latitude, shelter.longitude],
        { icon }
      ).addTo(this.map)

      marker.bindPopup(`
        <strong>${this.escapeHtml(shelter.name || "Shelter")}</strong><br/>
        ${this.escapeHtml(shelter.address || "")}<br/>
        Vacancies: ${shelter.vacancies ?? 0} / ${shelter.capacity ?? 0}
      `)
    })

    // ❌ DO NOT USE FITBOUNDS — IT OVERRIDES THE CENTER
    // Removed on purpose
  }

  markerStyleFor(shelter) {
    const capacity = shelter.capacity || 0
    const vacancies = shelter.vacancies || 0

    if (capacity <= 0) {
      return { color: "#6b7280", label: "?" }
    }

    const ratio = vacancies / capacity

    if (vacancies === 0) {
      return { color: "#ef4444", label: vacancies.toString() }
    } else if (ratio < 0.5) {
      return { color: "#facc15", label: vacancies.toString() }
    } else {
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
