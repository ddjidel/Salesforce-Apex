/**
 * Controller for Direct File Transfer LWC
 *
 * @author  Dalil Djidel (dalil.djidel@salesforce.com)
 * @version 1.0
 *
 * History
 * -------
 * v1.0 - 09-17-2023 - Initial Version
 * 
 * License
 * -------
 * Creative Commons Zero v1.0 Universal
 * 
 */

public with sharing class DocuwareController {
    @AuraEnabled(cacheable = true)
    public static string getToken(){
        try {
            String userName = 'xxx@xxx.com';
            String passPhrase = 'xxxxxxxxxxx';
    
            Http http = new Http();
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpRes = new HttpResponse();
    
            String url = 'https://xxxxx';
    
            Body body = new Body();
            body.UserName = userName;
            body.Passphrase = passPhrase;
    
            httpReq.setEndpoint(url);
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setBody(JSON.serialize(body));
    
            httpRes = http.send(httpReq);
                
            return(String.valueOf(httpRes.getBody()));            
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Body {
        public String UserName { get; set; }
        public String Passphrase { get; set; }
    }
}
