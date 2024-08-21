import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import "leaflet.markercluster"
import donutCluster from "leaflet-donutcluster"
// import "leaflet-draw"

var LeafIcon  = L.Icon.extend({
  options: {
    iconSize:     [40, 40],
    iconAnchor:   [40, 40],
    popupAnchor:  [-19, -40]
  }
});

var customIcon = new LeafIcon({iconUrl: 'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/070cafa4-d3a5-4cd0-98ae-50eeb3faceaf/d6bpee1-01f2b590-df25-43ea-b70f-3b6c33880e38.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzA3MGNhZmE0LWQzYTUtNGNkMC05OGFlLTUwZWViM2ZhY2VhZlwvZDZicGVlMS0wMWYyYjU5MC1kZjI1LTQzZWEtYjcwZi0zYjZjMzM4ODBlMzgucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.0I2UcdVbzq8_s1nBncZAXUe-pNxjGjAeD1nGJ1XOFQA'});
L.icon = function (options) {
  return new L.Icon(options);
};

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
        key: 'isic_2_dig_description',
        arcColorDict: colors
      });

    entreprises.forEach(entreprise => {
      let name = entreprise.raison_sociale_rgpd ?? '';

      if (name != ''){
        let lieuxDit = entreprise.lieux_dit ?? '';
        lieuxDit = lieuxDit != '' ? lieuxDit + ' - ' : '';
        let commune = '${entreprise.ville}/${entreprise.commune}';
        commune = commune.replace(`${entreprise.ville}/`, '');

        var popupContent = `
          <b>${name}</b> 
          <b>Addresse : ${lieuxDit}${entreprise.quartier ?? ''}</b>
          <b>Commune : ${commune}</b>
          <b>Département : ${entreprise.departement} ${entreprise.boite_postale} </b>
          <b>Activité:</b> ${entreprise.activite}<br>
          <b>Cameroun class. :</b> ${entreprise.npc_intitule}<br>
          <b>ILO ISIC class. :</b> ${entreprise.isic_refined} : ${entreprise.isic_refined_intitule}
        `;
      } else {
        var popupContent = `
          <b>Activité:</b> ${entreprise.activite}<br>
          <b>Cameroun class. :</b> ${entreprise.npc_intitule}<br>
          <b>ILO ISIC class. :</b> ${entreprise.isic_refined} : ${entreprise.isic_refined_intitule}
        `;
      }

      var marker = L.marker([entreprise.latitude, entreprise.longitude], {icon: customIcon}).bindPopup(popupContent);
      marker.options.isic_2_dig_description = entreprise.isic_2_dig_description;
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
