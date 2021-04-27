import { Component, OnInit, ViewChild, AfterViewInit } from '@angular/core';
import { } from 'googlemaps';
import { ContainerService } from 'src/app/services/container-service.service';
import { IDumpsterMeasure, Priority } from 'src/app/models/IDumpsterMeasure';
import {ProgressBarModule} from 'primeng/progressbar';

@Component({
  selector: 'app-measures',
  templateUrl: './measures.component.html',
  styleUrls: ['./measures.component.css']
})
export class MeasuresComponent implements OnInit, AfterViewInit { 

  containersLst: IDumpsterMeasure[];
  markers: google.maps.Marker[] = [];
  markerEvents: google.maps.event[]= [];
  arrStreetPath = [];
  features: any[];
  iconBase = './assets/images/1x/';
  icons = {
    whiteDumpster: { icon: this.iconBase + 'baseline_delete_white.png' },
    blackDumpster: {
      icon: this.iconBase + 'baseline_delete_black.png'
    },
    greenDumpster: {
      icon: this.iconBase + 'baseline_delete_green.png'
    },
    orangeDumpster: {
      icon: this.iconBase + 'baseline_delete_orange.png'
    },
    redDumpster: {
      icon: this.iconBase + 'baseline_delete_red.png'
    },
    yellowDumpster: {
      icon: this.iconBase + 'baseline_delete_yellow.png'
    },
    purpleDumpster: {
      icon: this.iconBase + 'baseline_delete_purple.png'
    }
  };

  @ViewChild('map') private mapElement: any;
  map: google.maps.Map;

  constructor(
    private containerService: ContainerService,
  ) { }

  ngOnInit(): void {
    const mapProperties = {
      center: new google.maps.LatLng(4.6365876,-74.0869373),
      zoom: 15.5 ,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    setTimeout(() => {
      this.map = new google.maps.Map(this.mapElement.nativeElement, mapProperties);
    }, 1000);
  }

  ngAfterViewInit(){
    google.maps.event.addDomListener(window, 'load', this.drawContainers);
  }

  drawContainers() {
    this.containerService.searchForRealContainer().subscribe(
      response => {

        this.containersLst = response;
        if (this.containersLst) {
          this.deleteMarkers();

          this.generateConfigMap();
          this.addMarkes();
        }
      }
    );
  }

  deleteMarkers() {
    this.markers.forEach(i => i.setMap(null));
    this.arrStreetPath.forEach(i => i.setMap(null));
  }

  addMarkes() {
    for (var i = 0; i < this.features.length; i++) {
      var marker = new google.maps.Marker({
        position: this.features[i].position,
        icon: this.features[i].type.icon,
        map: this.map
      });
      this.markers.push(marker);

      var contentString = '<p><strong>'+ this.features[i].label +'</strong></p>' +
      '<p><em>Date: </em>' + this.features[i].date + '</p>' +
      '<p><em>Level: </em> '+ this.features[i].levelDescription +'</p>'+
      '<div class="w3-light-grey"> <div class="w3-container w3-green w3-center" style="width:'+ this.features[i].level +'%">'+ this.features[i].level +'%</div> </div><br>';
      this.addInfoWindow(marker, contentString);
      // this.markerEvents.push(mapEvent);
    };
  }

  addInfoWindow(marker, message) {

    var infoWindow = new google.maps.InfoWindow({
        content: message
    });

    google.maps.event.addListener(marker, 'click', function () {
        infoWindow.open(this.map, marker);
    });
}

  generateConfigMap() {
    this.features = [];
    for (const container of this.containersLst) {
      const point = container.idDumpster.location.coordinates;
      this.features.push({
        position: new google.maps.LatLng(parseFloat(point[1] + ''), parseFloat(point[0] + '')),
        type: this.priorityIcon(container.priority),
        label: container.idDumpster.deviceID,
        date: container.measureDate,
        levelDescription: container.priority.priorityName,
        level: container.level
      });
    }

  }

  priorityIcon(priority: Priority) {
    switch (priority.priorityName) {
      case "Full":
        return this.icons.redDumpster;
      case "High":
        return this.icons.yellowDumpster;
      case "Medium":
        return this.icons.purpleDumpster;
      case "Low":
        return this.icons.greenDumpster;
      case "Empty":
        return this.icons.blackDumpster;
      default:
        return this.icons.whiteDumpster;
    }

  }

}
