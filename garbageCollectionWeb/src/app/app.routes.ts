

import { AuthGuard } from './Services/auth.guard';
import { DashBoardComponent } from './Views/dash-board/dash-board.component';
import { MeasuresComponent } from './Views/measures/measures.component'
import { Routes, RouterModule } from '@angular/router';
import { ModuleWithProviders } from '@angular/core';
import { LoginComponent } from './Views/login/login.component';
import { HomeComponent } from './Views/Pages/home/home.component';
import { TestingComponent } from './Views/testing/testing.component';





export const routes: Routes = [
    { path: '', component: LoginComponent },
    { path: 'Login/:token', component: LoginComponent },
    { path: 'Login/:token/:route', component: LoginComponent },
    {
        path: 'dashboard', component: DashBoardComponent, canActivate: [AuthGuard],
        children: [ // rutas hijas, se verán dentro del componente padre

            { path: '', component: HomeComponent },
            
        ]
     },
     { path: 'measures', component: DashBoardComponent ,
       children: [
           {path: '', component:  MeasuresComponent}
       ]
    },
    { path: 'testing', component: DashBoardComponent ,
        children: [
        {path: '', component:  TestingComponent}
        ]
    },
    // {
    //     path: 'Analitica', component: DashBoardComponent, canActivate: [AuthGuard],
    //     children: [ // rutas hijas, se verán dentro del componente padre
    //         { path: 'alertaFrecuencia', component: AlertaFrecuenciaComponent },
    //         { path: 'IngresosXsedes', component: IngresosXsedesComponent },
    //         { path: 'PacienteSinMedicoAsignado', component: PacienteSinMedicoAsignadoComponent },
    //         { path: 'MuestrasPendientesXsedes', component: MuestrasPendientesXsedesComponent },
    //     ]
    // },

];

export const AppRoutes: ModuleWithProviders = RouterModule.forRoot(routes);
