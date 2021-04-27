import { UserService } from './user.service';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import {
  HttpInterceptor, HttpRequest, HttpHandler,
  HttpSentEvent, HttpHeaderResponse, HttpProgressEvent, HttpResponse, HttpUserEvent
} from '@angular/common/http';


@Injectable()
export class AuthInterceptorService implements HttpInterceptor {

  constructor(private userService: UserService) { }

  intercept(req: HttpRequest<any>, next: HttpHandler):
    Observable<HttpSentEvent | HttpHeaderResponse | HttpProgressEvent | HttpResponse<any> | HttpUserEvent<any>> {
    if (!req.url.includes('/auth') ) {
      const token = this.userService.obtenerToken();
      req = req.clone({
        setHeaders: { Authorization:  token }
      });
    }

    return next.handle(req);
  }
}
