import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';
import { IDumpsterMeasure } from '../models/IDumpsterMeasure';

@Injectable({
  providedIn: 'root'
})
export class ContainerService {

  apiURL = environment.apiUrl + 'api/containers/'

  constructor(private httpClient: HttpClient) { }

  generateContainers(filled: boolean, date: string): Observable<IDumpsterMeasure[]> {
    const uri = (this.apiURL + 'generateLevels/') + (filled ? date  : '');
    return this.httpClient.get<IDumpsterMeasure[]>(uri);
  }

searchForRealContainer(): Observable<IDumpsterMeasure[]> {
    const uri = (this.apiURL + 'fetchLastMeasures/');
    return this.httpClient.get<IDumpsterMeasure[]>(uri);
  }
  

}
