import { Type, Location } from "./Type";

    export interface Dumpster {
        id: number;
        location: Location;
        idDumpsterType: number;
        idPhysicalState: number;
        idvia: number;
        deviceID: string;
    }
    
    export interface Priority {
        id: number;
        priorityDescription: string;
        priorityName: string;
        routeList?: any;
        measureDumpterList?: any;
    }

    export interface IDumpsterMeasure {
        id: number;
        level: number;
        measureDate: Date;
        idDumpster: Dumpster;
        priority: Priority;
    }




