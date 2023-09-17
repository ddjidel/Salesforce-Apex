/**
 * Custom Trigger to replicate custom object Chatter Post to Opportunity Chatter Post
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

trigger SyncChatterFeeds on FeedItem (after insert, after update) {
    for(FeedItem feedItem : Trigger.new) {
        Id parentId;
        parentId = feedItem.ParentId;

        String sobjectType = parentId.getSObjectType().getDescribe().getName();
        String title;
        String message;
        FeedItem opportunityFeedItem;

        if(sobjectType == 'Projet__c') {
            try{
                Projet__c project = [SELECT Name FROM Projet__c WHERE Id = :parentId];
                Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Projet__c = :parentId];
                List<OpportunityTeamMember> opportunityTeamMembers = [SELECT UserId FROM OpportunityTeamMember WHERE OpportunityId = :opportunity.Id];

                opportunityFeedItem = new FeedItem();

                opportunityFeedItem.ParentId = opportunity.Id;
                opportunityFeedItem.Body = feedItem.Body;
                opportunityFeedItem.IsRichText = feedItem.IsRichText;
                opportunityFeedItem.LinkUrl = feedItem.LinkUrl;
                opportunityFeedItem.NetworkScope = feedItem.NetworkScope;
                opportunityFeedItem.Revision = feedItem.Revision;
                opportunityFeedItem.Status = feedItem.Status;
                opportunityFeedItem.Title = feedItem.Title;
                opportunityFeedItem.Type = feedItem.Type;
                opportunityFeedItem.Visibility = 'InternalUsers';

                if(Trigger.isInsert) {
                    insert opportunityFeedItem;

                    ChatterPostMapping__c chatterPostMapping = new ChatterPostMapping__c(SourceFeedItemId__c = feedItem.Id, TargetFeedItemId__c = opportunityFeedItem.Id);

                    insert chatterPostMapping;

                    title = 'Nouveau post Chatter';
                    message = 'Nouveau post Chatter sur le projet ' + project.Name;
                }
                else if (Trigger.isUpdate) {
                    ChatterPostMapping__c chatterPostMapping = [SELECT TargetFeedItemId__c FROM ChatterPostMapping__c WHERE SourceFeedItemId__c = :feedItem.Id LIMIT 1];
                    opportunityFeedItem = [SELECT Body FROM FeedItem WHERE Id = :chatterPostMapping.TargetFeedItemId__c];

                    opportunityFeedItem.Body = feedItem.Body;

                    update opportunityFeedItem;

                    title = 'Post Chatter modifié';
                    message = 'Post Chatter modifié sur le projet ' + project.Name;
                }
                
                CustomNotificationType notification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'NewChatterPost'];
                List<String> userIds = new List<String>();
                
                for(OpportunityTeamMember opportunityTeamMember : opportunityTeamMembers) {
                    userIds.add(opportunityTeamMember.UserId);
                }

                HelperMethods.NotifyUser(title, message, userIds, notification.Id);
            }
            catch(Exception e){
                System.debug('Exception in CNRSSyncChatterFeeds: ' + e.getMessage());
            }
        }
    }
}