/**
 * Various Apex helper methods
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

global with sharing class HelperMethods {
    @future (callout=true)
    global static void NotifyUser(String title, String message, List<String> userIds, Id notificationId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v58.0/actions/standard/customNotificationAction');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');

        CustomNotificationActionInput input = new CustomNotificationActionInput();
        input.customNotifTypeId = notificationId;
        input.recipientIds = userIds;
        input.title = title;
        input.body = message;
        input.targetId = notificationId;

        CustomNotificationAction action = new CustomNotificationAction();
        action.inputs = new List<CustomNotificationActionInput>{input};

        req.setBody(JSON.serialize(action));

        res = http.send(req);
    }

    global class CustomNotificationAction {
        public List<CustomNotificationActionInput> inputs { get; set; }
    }

    global class CustomNotificationActionInput {
        public String customNotifTypeId { get; set; }
        public List<String> recipientIds { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String targetId { get; set; }
    }
}