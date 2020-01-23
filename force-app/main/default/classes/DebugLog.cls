/*
  DebugLog class
  provides a method of saving logs in a custom object
 
  Methods:
  DebugLog(String CallerIdentification)
    CallerIdentification is a string that identifies the process that created the entry
  saveLog(String LogEntry)
    LogEntry is a string that provides the data to be logged
    can be called multiple times to append to the log
  commitLog(String LogEntry)
    LogEntry is a string that provides data to be logged
    Calling this method saves the data in the custom object and clears the log string
    (but leaves the CallerIdentification intact)   

    Marc D Behr    
*/

public with sharing class DebugLog {

	private String logData { set; get { if (logData == null) { logData = ''; } return logData; } }
	private string caller { set; get; }
    private Boolean publishEvent { set; get; }
	public string endPoint { public set; private get { if (endPoint == null) { endPoint = 'undefined'; } return endPoint; } }

 
	public DebugLog(String procedure) {
		caller = procedure;
        Debug_Logger_Setting__mdt[] localSettings = [Select Publish_Events__c from Debug_Logger_Setting__mdt where DeveloperName = 'Local'];
        if(null != localSettings) {
            publishEvent = true; // publish by default
        } else {
            publishEvent = localSettings[0].Publish_Events__c;
        }
	}

	public void saveLog(String entry) {
		logData += entry + '\n';
	}

	public void commitLog(String entry) {
		logData += entry + '\n';
		try {
			DebugInfo__c debugInfo = new DebugInfo__c(
                Caller__c = caller.abbreviate(SObjectType.DebugInfo__c.Fields.Caller__c.Length), 
                DebugData__c = obscurePasswords(logData).abbreviate(SObjectType.DebugInfo__c.Fields.DebugData__c.Length), 
                EndPoint__c = endPoint.abbreviate(SObjectType.DebugInfo__c.Fields.EndPoint__c.Length)
            );
			insert debugInfo;

            if (publishEvent) {
                // publish the platform event 
                Debug_Log__e debugEvent = new Debug_Log__e(
                    Caller__c = caller.abbreviate(SObjectType.Debug_Log__e.Fields.Caller__c.Length),
                    DebugData__c = obscurePasswords(logData).abbreviate(SObjectType.Debug_Log__e.Fields.DebugData__c.Length),
                    EndPoint__c = endPoint.abbreviate(SObjectType.Debug_Log__e.Fields.EndPoint__c.Length) 
                );
                system.debug(debugEvent);
                EventBus.publish(debugEvent);
            }
            
			logData = '';

		}

		catch(Exception e) {
			//silently ignore
			system.debug('Exception occurred: ' + e.getMessage());
		}
	}

	private string obscurePasswords(string input) {
		// replace any passwords with *'s in the logged messages
		return input.replaceAll('([pP]assword)=([^,\\s]+)\\s?', '$1=******');
	}
}