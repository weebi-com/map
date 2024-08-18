import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import "leaflet.markercluster"
import donutCluster from "leaflet-donutcluster"

var LeafIcon  = L.Icon.extend({
  options: {
      // shadowUrl: 'location_icon.png',
      iconSize:     [40, 40],
      //shadowSize:   [50, 64],
      iconAnchor:   [40, 40],
      //shadowAnchor: [4, 62],
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
        key: 'isic_intitule',
        arcColorDict: colors
      });

    entreprises.forEach(entreprise => {
      if(2+2 == 4){
        let _lieuxDit = entreprise.lieux_dit === '' ? entreprise.lieux_dit + ' - ' : '';
        let _commune = entreprise.commune.replace(`${entreprise.ville}`, '');
        var popupContent = `
        <b>Raison Sociale : </b>${entreprise.raison_sociale_rgpd === '' ? 'Protégé RGPD' : entreprise.raison_sociale_rgpd}</br>
        <b>Forme Juridique : </b>${entreprise.forme}</br>
        <b>Addresse : </b>${_lieuxDit} ${entreprise.quartier ?? ''}</br>
        <b>Commune : </b>${_commune}${entreprise.ville}</br>
        <b>Département : </b>${entreprise.departement ?? ''} ${entreprise.boite_postale} </br>
        <b>Activité :</b> ${entreprise.activite}</br>
        <b>Classe Cameroun : </b>${entreprise.npc} - ${entreprise.npc_intitule}</br>
        <b>Classe ISIC (ILO): </b>${entreprise.isic_refined} - ${entreprise.isic_intitule}</br>
        `;
        } else {
          var popupContent = `
        <b>Activité:</b> ${entreprise.activite}<br>
        <b>Classe Cameroun : </b>${entreprise.npc} - ${entreprise.npc_intitule}<br>
        <b>Classe ISIC (ILO): </b>${entreprise.isic_refined} - ${entreprise.isic_intitule}</br>
        `;
        }
        // no use displaying below classes
        // <b>ISIC 1 Dig:</b> ${entreprise.isic_1_dig}<br>
        // <b>ISIC 2 Dig:</b> ${entreprise.isic_2_dig}<br>
        // <b>ISIC 3 Dig:</b> ${entreprise.isic_3_dig}<br>
        // <b>ISIC 4 Dig:</b> ${entreprise.isic_4_dig}<br>
        
      var marker = L.marker([entreprise.latitude, entreprise.longitude], {icon: customIcon}).bindPopup(popupContent);
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
