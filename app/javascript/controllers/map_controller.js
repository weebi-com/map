import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import "leaflet.markercluster"
import donutCluster from "leaflet-donutcluster"

donutCluster(L);

// Connects to data-controller="map"
export default class extends Controller {
  static targets = ["mapContainer"]
  
  connect() {  
    this.createMap();
    this.fetchEntreprisesData();
  }

  createMap() {
    this.map = L.map(this.mapContainerTarget).setView([7.3697, 12.3547], 6);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(this.map);
  }

  
  getCategorieDescriptionByCode(code, categories) {
    const categorie = categories.find((category) => category.code == code);

    return categorie.description || "-"
  }

  addMarkersToMap(entreprises, categories, colors) {
    let markers = new L.DonutCluster(
      { chunkedLoading: true },
      {
        key: 'isic_intitule',
        arcColorDict: colors
      });

    entreprises.forEach(entreprise => {
      var popupContent = `
        <b>Activité:</b> ${entreprise.activite}<br>
        <b>Intitulé NPC:</b> ${entreprise.npc_intitule}<br>
        <b>ISIC Refined:</b> ${this.getCategorieDescriptionByCode(entreprise.isic_refined, categories)}<br>
        <b>ISIC 1 Dig:</b> ${this.getCategorieDescriptionByCode(entreprise.isic_1_dig, categories)}<br>
        <b>ISIC 2 Dig:</b> ${this.getCategorieDescriptionByCode(entreprise.isic_2_dig, categories)}<br>
        <b>ISIC 3 Dig:</b> ${this.getCategorieDescriptionByCode(entreprise.isic_3_dig, categories)}<br>
        <b>ISIC 4 Dig:</b> ${this.getCategorieDescriptionByCode(entreprise.isic_4_dig, categories)}<br>
        <b>ISIC Intitulé:</b> ${entreprise.isic_intitule}
      `;

      var marker = L.marker([entreprise.latitude, entreprise.longitude]).bindPopup(popupContent);
      marker.options.isic_intitule = entreprise.isic_intitule;
      markers.addLayer(marker);
    });

    this.map.addLayer(markers);
  }

  fetchEntreprisesData() {
    fetch('/api/v1/entreprises')
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(data => {          
        if (data.entreprises && Array.isArray(data.entreprises)) {
          this.addMarkersToMap(data.entreprises, data.categories, data.colors);
        } else {
          console.error('Data format error: Expected entreprises array');
        }
      })
      .catch(error => {
        console.error('Error fetching or parsing data:', error);
      });
  }

  disconnect() {
    this.map.remove();
  }
}
