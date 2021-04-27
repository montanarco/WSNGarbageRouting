import { Component, OnInit } from '@angular/core';
import { CustomMessage } from '../../CustomMessage';
import {Observable} from 'rxjs';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {
  fechaactual: Date;
  unmesAtras: Date;
  es: {};
  constructor( 
    public customMessage: CustomMessage
    ) {
   
    this.fechaactual = new Date();
    this.unmesAtras = this.dateFromDay(30);
    this.es = {
      firstDayOfWeek: 1,
      dayNames: ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'],
      dayNamesShort: ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'],
      dayNamesMin: ['D', 'L', 'M', 'X', 'J', 'V', 'S'],
      monthNames: ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'],
      monthNamesShort: ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
      today: 'Hoy',
      clear: 'Borrar'
    };
    //const route: Observable<string> = route.url.pipe(map(segments => segments.join('')))
  }

  ngOnInit() {
    /*this.buscarContador('pacientes');
    this.buscarContador('remitidos');
    this.buscarContador('citologias');
    this.buscarContador('patologias');
    this.buscarContador('laboratorio');
    */
  }

  
  dateFromDay(day): Date {
    const date = new Date();
    date.setDate(date.getDate() - day);
    return date;
  }


}
