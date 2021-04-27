import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Router } from '@angular/router';


@Injectable({
  providedIn: 'root'
})
export class UserService {

  // _userActionOccured: Subject<void> = new Subject();
  // get userActionOccured(): Observable<void> { return this._userActionOccured.asObservable(); }
  private apiURL = environment.apiUrl ;
  constructor(private router: Router, private http: HttpClient) { }

  userAuthentication(userName, pass) {

    sessionStorage.setItem('u', userName);
    sessionStorage.setItem('p', pass);


    const reqHeaders = new HttpHeaders({ 'Content-Type': 'application/json' });
    // reqHeaders.set('Access-Control-Allow-Origin', 'http://localhost:8080');
    const user = {
      username: userName,
      password: pass
    };
    const sampleJSON = JSON.stringify(user);
     console.log('objeto user a enviar->' + sampleJSON);
    return this.http.post(this.apiURL + 'auth', sampleJSON, { headers: reqHeaders });
  }

  validateToken() {
    return this.http.get(this.apiURL + 'test/validateToken');
  }

  obtenerToken(): string {
    return localStorage.getItem('UserToken');
  }

  obtenerExpiracionToken(): string {
    return localStorage.getItem('tokenExpiration');
  }

  logout() {
    localStorage.removeItem('UserToken');
    localStorage.removeItem('tokenExpiration');
    sessionStorage.removeItem('u');
    sessionStorage.removeItem('p');
    localStorage.clear();
    this.router.navigate(['/']);
  }

  estaLogueado(): boolean {

    const exp = this.obtenerExpiracionToken();

    if (!exp) {
      // el token no existe
      return false;
    }

    const now = new Date().getTime();
    const dateExp = new Date(exp);

    if (now >= dateExp.getTime()) {// el tiempo del token expiró
      const u = sessionStorage.getItem('u');
      const p = sessionStorage.getItem('p');
      this.userAuthentication(u, p).subscribe((r: any) => {
        localStorage.setItem('UserToken', r.token);
        localStorage.setItem('tokenExpiration', r.expiration);
        return true;
      },
        (err: HttpErrorResponse) => {
          return false;
        });
      // ya expiró el token
      /*
      localStorage.removeItem('UserToken');
      localStorage.removeItem('tokenExpiration');
      return false;
      */
    } else {
      return true;
    }

  }
}
