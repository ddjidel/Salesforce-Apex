import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getToken from '@salesforce/apex/DocuwareController.getToken';

export default class TransientFileUploader extends LightningElement {
    token;
    error;
    fileData;

    @api recordId;
    @wire(getToken)
    wiredToken({ error, result }) {
        if (result) {
            this.token = result;
            this.error = undefined;

            console.log('token', this.token);

            let payload = {
                'Token': this.token,
                'LicenseType': 'WebClient',
                'RememberMe': 'false'
            };

            let formBody = [];

            for (let property in payload) {
                let encodedKey = encodeURIComponent(property);
                let encodedValue = encodeURIComponent(payload[property]);
                formBody.push(encodedKey + "=" + encodedValue);
            }

            formBody = formBody.join("&");

            console.log('formBody', formBody);

            fetch('https://bgs.docuware.cloud/DocuWare/Platform/Account/TokenLogOn', {
                method: 'POST',
                mode: "no-cors",
                headers:{
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json'
                },    
                body: formBody
            })
            .then(response => response.text())
            .then(data => console.log(data));

        } else if (error) {
          this.error = error;
          console.log('error', this.error);
        }
    }

    /*
    openfileUpload(event) {
        const file = event.target.files[0];
        var reader = new FileReader();

        reader.onload = () => {
            var base64 = reader.result.split(',')[1];

            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            };
        }

        reader.readAsDataURL(file);
    }
    
    handleClick(){
        const {filename, base64, recordId} = this.fileData;

        let title = `Connection à DocuWare réussie`;
        this.toast(title);

        title = `${filename} chargé dans DocuWare`;
        this.toast(title);
    }
    */

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        });

        this.dispatchEvent(toastEvent);
    }
}
