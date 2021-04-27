import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { IKmeansResult } from '../models/IDailyOperation';

@Injectable({
  providedIn: 'root'
})
export class ClusterService {

  apiURL = environment.apiUrl + 'api/cluster'

  constructor(private httpClient: HttpClient) { }

  clusterStreets(date: String): Observable<IKmeansResult> {
    const uri = this.apiURL + '/streets/' + date;
    return this.httpClient.get<IKmeansResult>(uri);
  }
}
