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

  addMarkersToMap(entreprises, categories, colors) {
    let markers = new L.DonutCluster(
      { chunkedLoading: true },
      {
        key: 'isic_intitule',
        arcColorDict: colors
      });

    entreprises.forEach(entreprise => {
      let name = entreprise.raison_sociale_rgpd ?? '';
      if(name != ''){
        let lieuxDit = entreprise.lieux_dit ?? '';
        lieuxDit = lieuxDit != '' ? lieuxDit + ' - ' : '';
        let commune = '${entreprise.ville}/${entreprise.commune}';
        commune = commune.replace(`${entreprise.ville}/`, '');
        var popupContent = `
        <b>${name}</b> 
        <b>Addresse : ${lieuxDit}${entreprise.quartier ?? ''}</b>
        <b>Commune : ${commune}</b>
        <b>Département : ${departement} ${boite_postale} </b>
        <b>Activité:</b> ${entreprise.activite}<br>
        <b>Cameroun class. :</b> ${entreprise.npc_intitule}<br>
        <b>ILO ISIC class. :</b> ${entreprise.isic_refined} : ${entreprise.isic_intitule}
        `;
        } else {
          var popupContent = `
        <b>Activité:</b> ${entreprise.activite}<br>
        <b>Cameroun class. :</b> ${entreprise.npc_intitule}<br>
        <b>ILO ISIC class. :</b> ${entreprise.isic_refined} : ${entreprise.isic_intitule}
        `;
        }
        // no use displaying below classes
        // <b>ISIC 1 Dig:</b> ${entreprise.isic_1_dig}<br>
        // <b>ISIC 2 Dig:</b> ${entreprise.isic_2_dig}<br>
        // <b>ISIC 3 Dig:</b> ${entreprise.isic_3_dig}<br>
        // <b>ISIC 4 Dig:</b> ${entreprise.isic_4_dig}<br>
        
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
