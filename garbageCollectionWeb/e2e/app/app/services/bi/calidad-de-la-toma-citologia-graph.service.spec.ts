import { TestBed, inject } from '@angular/core/testing';

import { CalidadDeLaTomaCitologiaGraphService } from './calidad-de-la-toma-citologia-graph.service';

describe('CalidadDeLaTomaCitologiaGraphService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [CalidadDeLaTomaCitologiaGraphService]
    });
  });

  it('should be created', inject([CalidadDeLaTomaCitologiaGraphService], (service: CalidadDeLaTomaCitologiaGraphService) => {
    expect(service).toBeTruthy();
  }));
});
