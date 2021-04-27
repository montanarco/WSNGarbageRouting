import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { IKmeansResult } from '../models/IDailyOperation';

@Injectable({
  providedIn: 'root'
})
export class DailyOperationService {

  apiURL = environment.apiUrl + 'api/dailyOperation'

  constructor(private httpClient: HttpClient) { }

  fetchDailyOperation(date: String): Observable<number> {
    const uri = this.apiURL + '/fetchDailyOperation/' + date;
    return this.httpClient.get<number>(uri);
  }
  createDailyOperation(date: String): Observable<boolean> {
    const uri = this.apiURL + '/createDailyOperation/' + date;
    return this.httpClient.get<boolean>(uri);
  }
}
