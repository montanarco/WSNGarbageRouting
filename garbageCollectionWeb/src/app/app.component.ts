import { environment } from './../environments/environment';
import { Component, AfterViewInit, ElementRef, Renderer2, ViewChild, OnDestroy, OnInit, NgZone, HostListener } from '@angular/core';
import { UserService } from './Services/user.service';
import { Subject, timer, Subscription } from 'rxjs';
import { takeUntil, take } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  endTime = 1;
  minutesDisplay = 0;
  secondsDisplay = 0;
  subscription: Subscription;

  constructor(public userService: UserService) {

  }

  @HostListener('document:keyup', ['$event'])
  @HostListener('document:click', ['$event'])
  @HostListener('document:wheel', ['$event'])
  resetTimer() {
    this.clearTimer();
    this.initTimer();
  }

  clearTimer() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  private initTimer() {

    const interval = environment.timeSession;
    console.log('Tiempo de session=' + interval);
    const duration = this.endTime * 60;

    this.subscription = timer(0, interval).pipe(
      take(duration)
    ).subscribe(value =>
      this.render((duration - +value) * interval),
      err => { },
      () => {
        this.userService.logout();
      }
    );
  }

  private render(count) {
    this.secondsDisplay = this.getSeconds(count);
    this.minutesDisplay = this.getMinutes(count);
    // console.log(this.minutesDisplay + ':' + this.secondsDisplay);
  }

  private getSeconds(ticks: number) {
    const seconds = ((ticks % 60000) / 1000).toFixed(0);
    return this.pad(seconds);
  }

  private getMinutes(ticks: number) {
    const minutes = Math.floor(ticks / 60000);
    return this.pad(minutes);
  }

  private pad(digit: any) {
    return digit <= 9 ? '0' + digit : digit;
  }
}
