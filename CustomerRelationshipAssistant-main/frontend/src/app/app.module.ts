import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { AppComponent } from './app.component';
import { TreatmentsApiService } from './treatments/treatments-api.service';
import { PopupComponent } from './popup/popup.component';

@NgModule({
  declarations: [AppComponent, PopupComponent],
  imports: [BrowserModule, CommonModule, HttpClientModule],
  providers: [TreatmentsApiService],
  bootstrap: [AppComponent],
})
export class AppModule {}
