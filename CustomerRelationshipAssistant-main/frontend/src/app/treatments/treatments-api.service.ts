import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable } from 'rxjs';
import { API_URL } from '../env';
import { Treatment } from './treatment.model';
import { catchError } from 'rxjs';

@Injectable()
export class TreatmentsApiService {
  constructor(private http: HttpClient) {}

  private static _handleError(err: any) {
    return 'Error: Unable to complete request.';
  }

  // GET list of public, future events
 // getTreatments(): Observable<Treatment[]> {
 //   return this.http.get<Treatment[]>(`${API_URL}/treatments`);
 //   /*.pipe(catchError(this._handleError))*/
 // }

  getTreatments(): Observable<Treatment[]> {
    var response = this.http.get<Treatment[]>(`${API_URL}treatments/as/as/as/as`);
    response.subscribe({
      next(_id){
        console.log(_id)
        console.log(_id.length)
        //var res = Object.keys(_id);
        //console.log(res);
      }
    });


  return response ;
}
}
