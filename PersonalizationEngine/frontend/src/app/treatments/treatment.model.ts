export class Treatment {
  constructor(
    public treatment_code: string,
    public product: string,
    public source_system?: string,
    public variant?: number,
    public _id?: number,
    public id_type?: string,
    public treatment_text?: string,
    public treatment_title?: string
  ) {}
}
