import { Component, OnInit, OnDestroy, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { TreatmentsApiService } from './treatments/treatments-api.service';
import { Treatment } from './treatments/treatment.model';
import { Observable } from 'rxjs';
import { PopupComponent } from './popup/popup.component';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent implements OnInit, OnDestroy {
  title = 'app';

  treatmentListSubs: Subscription;
  treatmentList:  Treatment[];//Observable<Treatment[]>;
  errorMessage!: string;

  @ViewChild(PopupComponent)
  menu!: PopupComponent;

  openMenu(e:MouseEvent) {
    this.menu.open(e)
  }

  itemSelected(item:number){
    console.log("Item", item)
  }

  constructor(private treatmentsApi: TreatmentsApiService) {
    this.treatmentList = new Array();
    this.treatmentListSubs = new Subscription();
  }

  ngOnInit() {
    this.treatmentListSubs = this.treatmentsApi
      .getTreatments()
      .subscribe((res) => {
        this.treatmentList = res;
      }, error => {
        this.errorMessage = error;
      });
  }

  ngOnDestroy() {
    this.treatmentListSubs.unsubscribe();
  }
}
