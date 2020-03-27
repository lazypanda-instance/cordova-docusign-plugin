import { Component } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { Platform } from '@ionic/angular';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {

  private docusignForm: FormGroup;

  constructor(private formBuilder: FormBuilder,
              private platform: Platform) {
    this.docusignForm = this.formBuilder.group({
      email: ['', Validators.required],
      password: ['']
    });
  }

  submitForm() {
    this.initializeDocuSign(this.docusignForm.value);
  }

  initializeDocuSign(formValue: any): void {
    if (this.platform.is('cordova')) {
      const win: any = window;
      if (win.docuSign) {
        win.docuSign.launchDocuSignSDK(`${formValue.email},${formValue.password},sample`, (message) => {
          console.log('DocuSign launch Successfully: ', message);
        }, (error) => {
          console.log('Error on loading plugin: ', error);
        });
      }
    }
  }
}
