/*
    debug_logger test classes

    Test the functionality of the main logger
    
    Marc D Behr
*/

@isTest
private class DebugTest {
	static list<DebugInfo__c> debugInfoList = new list<DebugInfo__c> ();
	static DebugLog debugLogs;
	static String realyBigString = '01234567890 error '.repeat(2200); // oversized string
	static String debugLogQuery = 'Select Id,DebugData__c from DebugInfo__c';

	static testMethod void LoggedPasswordsAreObscured() {
		Test.startTest();
		debugLogs = new DebugLog('DebugTest');
		debugLogs.commitLog('Test0,Password=ABc123,');
		Test.stopTest();
		debugInfoList = (list<DebugInfo__c>) database.query(debugLogQuery);
		system.assertequals(1, debugInfoList.size());
		system.assert(debugInfoList[0].DebugData__c.contains('Test0'));
		system.assert(debugInfoList[0].DebugData__c.contains('Password=*****'));
	}

	static testMethod void LongStringsAreTruncated() {
		Test.startTest();
		debugLogs = new DebugLog('DebugTest');
		debugLogs.saveLog('Test');
		debugLogs.commitLog(realyBigString);
		Test.stopTest();
		debugInfoList = (list<DebugInfo__c>) database.query(debugLogQuery);
		system.assertequals(1, debugInfoList.size());
		system.assertequals('...', debugInfoList[0].DebugData__c.right(3));
		system.assertequals(SObjectType.DebugInfo__c.Fields.DebugData__c.Length, debugInfoList[0].DebugData__c.length());
	}

	static testMethod void LogsAreNotWrittenDuringReadOnlyMode() {
		// Set the application read only mode.
		Test.setReadOnlyApplicationMode(true);
		Test.startTest();
		debugLogs = new DebugLog('DebugTest');
		debugLogs.commitLog('ReadOnlyModeTest');
		Test.stopTest();
		debugInfoList = (list<DebugInfo__c>) database.query(debugLogQuery);
		system.assertequals(0, debugInfoList.size());
	}

}