import { Component, OnInit, Renderer2 } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { UserService } from '../../Services/user.service';
import { HttpErrorResponse } from '@angular/common/http';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { CustomMessage } from '../CustomMessage';
import { Location } from '@angular/common';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  tokenParam = 'initial value';
  pathParam = 'initial value';
  isLoginError = false;
  registerForm: FormGroup;
  submitted = false;
  username: String;
  password: String;
  constructor(private renderer: Renderer2, private router: Router, private userService: UserService,
    public customMessage: CustomMessage,
    private _location: Location,
    private formBuilder: FormBuilder, private readonly route: ActivatedRoute) { }

  ngOnInit() {
    this.tokenParam = this.route.snapshot.paramMap.get('token');
    this.pathParam = this.route.snapshot.paramMap.get('route');

    if (this.tokenParam != null && this.tokenParam !== '') {
        localStorage.setItem('UserToken', this.tokenParam);
        localStorage.setItem('tokenExpiration', '30');
        this.userService.validateToken().subscribe(( x: any) => {
            if (x.response === 'Success') {
                if (this.pathParam != null && this.pathParam !== '') {
                    this.router.navigate(['/' + this.pathParam.replace('-', '/') ]);
                  } else {
                    this.router.navigate(['/dashboard']);
                  }
            } else {
                this._location.back();
            }
        },
        ( error: any ) => {
            this.userService.logout();
            this._location.back();
            console.log('No fue autorizado');
        }
        );


    }
    this.registerForm = this.formBuilder.group({
      user: ['', Validators.required],
      password: ['', [Validators.required, Validators.minLength(3)]]
    });
  }

  get f() { return this.registerForm.controls; }



  loginUser(e) {
    e.preventDefault();
    this.submitted = true;

    // stop here if form is invalid
    if (this.registerForm.invalid) {
      return;
    }

    this.username = e.target.elements[0].value;
    this.password = e.target.elements[1].value;

    this.userService.userAuthentication(this.username, this.password).subscribe((data: any) => {
      localStorage.setItem('UserToken', data.token);
      localStorage.setItem('tokenExpiration', data.expiration);
      this.router.navigate(['/dashboard']);
    },
      (err: HttpErrorResponse) => {
        if (err.error.Error !== undefined) {
          this.customMessage.showError('Error', err.error.Error);
        }
        this.isLoginError = true;
        e.target.elements[0].value = '';
        e.target.elements[1].value = '';
      });
  }


  onBlurMethod(e) {
    if (e.target.value !== '') {
      // this.renderer.setElementClass(event.target,"opened",true);
      this.renderer.addClass(e.target, 'ui-state-filled');
    } else {
      this.renderer.removeClass(e.target, 'ui-state-filled');
    }

  }
}


