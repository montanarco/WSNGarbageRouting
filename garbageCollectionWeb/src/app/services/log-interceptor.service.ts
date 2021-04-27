import { state } from '@angular/animations';
import { UserService } from './user.service';
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { map, filter, tap, catchError, finalize } from 'rxjs/operators';
// import 'rxjs/Observable';
// import 'rxjs/add/observable/throw';
import {
    HttpInterceptor, HttpRequest, HttpHandler,
    HttpSentEvent, HttpHeaderResponse, HttpProgressEvent, HttpResponse, HttpUserEvent, HttpErrorResponse,
    HttpEvent
} from '@angular/common/http';

import { throwError } from 'rxjs';


@Injectable()
export class LogInterceptorService implements HttpInterceptor {

    constructor(private userService: UserService) { }
    intercept(req: HttpRequest<any>, next: HttpHandler):
        Observable<HttpSentEvent | HttpHeaderResponse | HttpProgressEvent | HttpResponse<any> | HttpUserEvent<any>> {
        const started = Date.now();
        return next.handle(req).pipe(
            tap(event => {
                if (event instanceof HttpResponse) {
                    const elapsed = Date.now() - started;
                     console.log(`Request for ${req.url} took ${elapsed} ms.`);
                     console.log(event.body);
                     console.log(event);
                    if (event.status === 401) {
                        alert('Se ha agotado el tiempo de session');
                        this.userService.logout();
                    }
                }
            }, error => {
                if (error instanceof HttpErrorResponse) {
                    switch ((<HttpErrorResponse>error).status) {
                        case 400:
                            console.log(error);
                            break;
                        case 401:
                            console.log(error);
                            this.userService.logout();
                            break;
                    }
                } else {
                    return throwError(error);
                }
                // this.userService.logout();
            })
        );
    }




}


@Injectable()
export class HTTPStatus {
    private requestInFlight$: BehaviorSubject<boolean>;
    constructor() {
        this.requestInFlight$ = new BehaviorSubject(false);
    }

    setHttpStatus(inFlight: boolean) {
        this.requestInFlight$.next(inFlight);
    }

    getHttpStatus(): Observable<boolean> {
        return this.requestInFlight$.asObservable();
    }
}

@Injectable()
export class HTTPListener implements HttpInterceptor {
    constructor(private status: HTTPStatus, private userService: UserService) { }
    intercept(
        req: HttpRequest<any>,
        next: HttpHandler
    ): Observable<HttpEvent<any>> {
        this.status.setHttpStatus(true);
        return next.handle(req).pipe(
            map(event => {
                return event;
            }),
            catchError(error => {

                return throwError(error);

            }),
            finalize(() => {
                this.status.setHttpStatus(false);
            })
        );
    }
}
