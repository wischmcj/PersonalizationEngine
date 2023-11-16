import { Component, OnInit, HostBinding, HostListener, Input } from '@angular/core';

@Component({
  selector: 'app-popup',
  templateUrl: './popup.component.html',
  styleUrls: ['./popup.component.css']
})
export class PopupComponent implements OnInit {
  @HostBinding("style.top") y = "0px"
  @HostBinding("style.left") x = "0px"
  @HostBinding("style.visibility") visibility = "hidden"
  @Input() @HostBinding("style.width") width = "200px"

  constructor() { }

  ngOnInit() {
  }

  open(e:MouseEvent) {
    this.x = `${e.pageX}px`
    this.y = `${e.pageY}px`

    this.visibility = "visible"

    e.stopPropagation()
  }

  close() {
    this.visibility = "hidden"
  }

  @HostListener('document:click')
  public onDocumentClick() {
    if (this.visibility === "visible") {
      this.close()
    }
  }
}
