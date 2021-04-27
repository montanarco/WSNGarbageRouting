import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
    providedIn: 'root'
  })
  export class RoutingService {
  
    apiURL = environment.apiUrl + 'api/routing'
  
    constructor(private httpClient: HttpClient) { }
  
    routingOperation(date: String): Observable<JSON> {
      const uri = this.apiURL + '/calculate/' + date;
      return this.httpClient.get<JSON>(uri);
    }


    getVehicleRoutes(): Observable<JSON> {
      const uri = this.apiURL + '/vehicles/05-11-2020';
      return this.httpClient.get<JSON>(uri);
    }
  }