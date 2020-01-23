/*
    debug_logger cleanup processor

    Cleans old records from the system
    
    Marc D Behr
*/

global  class DebugCleanup implements Database.batchable<sObject> {

     global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer daysToKeep;
        if(Test.isRunningTest()) {
            daysToKeep = 2; // in the future to ensure that all logs will be deleted when running tests
        } else {
            // look for the local settings
            Debug_Logger_Setting__mdt[] localSettings = [Select Days_To_Keep__c from Debug_Logger_Setting__mdt where DeveloperName = 'Local'];
            if(null != localSettings) {
                daysToKeep = Integer.valueOf(-(localSettings[0].Days_To_Keep__c));
            } else {
                daysToKeep = -2; // default to 2 days ago
            }
        }

        String dateString = String.valueof(Date.today().adddays(daysToKeep)).substringBefore(' ')+'T00:00:00Z';
        system.debug('Selecting records before ' + dateString);

		String query = 'select id from debuginfo__c where Created_Time__c < '+dateString ;
        return Database.getQueryLocator(query);
     }

    global void execute(Database.BatchableContext BC, List<debuginfo__c> scope){
		delete scope;
		DataBase.emptyRecycleBin(scope);
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}