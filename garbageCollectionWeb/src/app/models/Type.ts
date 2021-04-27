export enum Type {
    MultiLineString = "MultiLineString",
    Point = "Point"
}

export interface Location {
    type:        Type;
    coordinates: number[];
}
