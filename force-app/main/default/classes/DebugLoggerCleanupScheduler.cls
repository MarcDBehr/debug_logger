/*
    debug_log cleanup scheduler

    Schedules the job that cleans old records from the system
    
    Marc D Behr
*/

public with sharing class DebugLoggerCleanupScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        database.executebatch(new DebugCleanup());
    }
}
