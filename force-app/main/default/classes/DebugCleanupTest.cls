/*
    debug_logger cleanup processor

    Tests the class that cleans old records from the system
    
    Marc D Behr
*/

@isTest
private class DebugCleanupTest {
	static list<DebugInfo__c> debugInfoList ;

	@TestSetup static void createRecords() {
		debugInfoList = new list<DebugInfo__c> ();

			for (integer i = 0; i < 200; i++) {
				debugInfoList.add(new DebugInfo__c(DebugData__c = 'Test ' + i));
			}
			insert debugInfoList;
	}

	static testMethod void  DebugLogsAreDeletedWhenBatchIsRun() {
		debugInfoList = [Select Id from DebugInfo__c];
		system.AssertEquals(200,debugInfoList.size());
		Test.startTest();
		Database.executeBatch(new DebugCleanup());
		Test.stopTest();
		debugInfoList = [Select Id from DebugInfo__c];
		system.AssertEquals(0,debugInfoList.size());
	}

}