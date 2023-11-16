import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PromowidgetComponent } from './promowidget.component';

describe('PromowidgetComponent', () => {
  let component: PromowidgetComponent;
  let fixture: ComponentFixture<PromowidgetComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ PromowidgetComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(PromowidgetComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
