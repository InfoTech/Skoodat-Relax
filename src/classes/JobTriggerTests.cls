@isTest
public class JobTriggerTests
{
  private static testMethod void TestJobTrigger_Update() {
      // Load up our page for a new Schedulable job record
      Job__c j = new Job__c(
        Name = 'Unit_Test_Individually_Scheduled_Job',
        Run_Individually__c = true,
        IsActive__c = true,
        Cron_Schedule__c = '0 0 13 * * ?',
        Apex_Class__c = 'relax.JobScheduler'
    );
    
    insert j;
    
      // Verify that our record saved
      List<Job__c> jobs = [
        select  Id, Apex_Class__c, IsActive__c, CronTriggerId__c, Next_Run__c, JobSchedulerId__c
        from  Job__c
        where Name = 'Unit_Test_Individually_Scheduled_Job' 
        order by CreatedDate DESC limit 1
      ];
      
      String triggerId = jobs[0].CronTriggerId__c;
      
      System.assertEquals(1,jobs.size());
      System.assertEquals('relax.JobScheduler',jobs[0].Apex_Class__c);
      System.assertEquals(true,jobs[0].IsActive__c);
      System.assertNotEquals(null,jobs[0].CronTriggerId__c);
      System.assertNotEquals(null,jobs[0].JobSchedulerId__c);
      System.assertNotEquals(null,jobs[0].Next_Run__c);
      
      // Verify that there is BOTH a CronTrigger record corresponding to this record
      // and a relax Job Scheduler record
      List<CronTrigger> cronJobs = [select Id from CronTrigger where Id = :triggerId limit 1];
      System.assertEquals(1,cronJobs.size());
      
      // Update our job, setting it to non-active
      j.IsActive__c = false;
      
      Test.startTest();
      
      update j;
      
      // Force our @future call to finish running
      Test.stopTest();
      
      // Our job should have its JobSchedulerId__c and CronTriggerId fields set to null
      jobs = [
        select  Id, Apex_Class__c, IsActive__c, JobSchedulerId__c, CronTriggerId__c, Next_Run__c
        from  Job__c
        where Name = 'Unit_Test_Individually_Scheduled_Job' 
        order by CreatedDate DESC limit 1
      ];
      System.assertEquals(null,jobs[0].CronTriggerId__c);
      System.assertEquals(null,jobs[0].JobSchedulerId__c);
      System.assertEquals(null,jobs[0].Next_Run__c); 
        
    }
    
    private static testMethod void TestJobTrigger_Delete() {
      // Load up our page for a new Schedulable job record
      Job__c j = new Job__c(
        Name = 'Unit_Test_Individually_Scheduled_Job',
        Run_Individually__c = true,
        IsActive__c = true,
        Cron_Schedule__c = '0 0 13 * * ?',
        Apex_Class__c = 'relax.JobScheduler'
    );
    
    insert j;
    
      // Verify that our record saved
      List<Job__c> jobs = [
        select  Id, Apex_Class__c, IsActive__c, CronTriggerId__c, JobSchedulerId__c, Next_Run__c
        from  Job__c
        where Name = 'Unit_Test_Individually_Scheduled_Job' 
        order by CreatedDate DESC limit 1
      ];
      
      String triggerId = jobs[0].CronTriggerId__c;
      
      System.assertEquals(1,jobs.size());
      System.assertEquals('relax.JobScheduler',jobs[0].Apex_Class__c);
      System.assertEquals(true,jobs[0].IsActive__c);
      System.assertNotEquals(null,jobs[0].CronTriggerId__c);
      System.assertNotEquals(null,jobs[0].JobSchedulerId__c);
      System.assertNotEquals(null,jobs[0].Next_Run__c);
      
      // Verify that there is a CronTrigger record corresponding to this record
      List<CronTrigger> cronJobs = [select Id from CronTrigger where Id = :triggerId limit 1];
      System.assertEquals(1,cronJobs.size());
      
      // Update our job, setting it to non-active
      j.IsActive__c = false;
      
      Test.startTest();
      
      delete j;
      
      // Force our @future call to finish running
      Test.stopTest();
      
      // Our job should have its CronTriggerId field set to null
      jobs = [select Id from Job__c where Name = 'Unit_Test_Individually_Scheduled_Job' limit 1];
      System.assertEquals(0,jobs.size());
        
    }
    
    private static testMethod void TestJobTrigger_Insert() {
      // Load up our page for a new Schedulable job record
      Job__c j = new Job__c(
        Name = 'Unit_Test_Individually_Scheduled_Job',
        Run_Individually__c = true,
        IsActive__c = true,
        Cron_Schedule__c = '0 0 13 * * ?',
        Apex_Class__c = 'relax.JobScheduler'
      );
      
      Test.startTest();
      
      insert j;
      
      Test.stopTest();
    
      // Verify that our record saved
      List<Job__c> jobs = [
        select  Id, Apex_Class__c, IsActive__c, CronTriggerId__c, JobSchedulerId__c, Next_Run__c
        from  Job__c
        where Name = 'Unit_Test_Individually_Scheduled_Job' 
        order by CreatedDate DESC limit 1
      ];
      
      String triggerId = jobs[0].CronTriggerId__c;
      
      System.assertEquals(1,jobs.size());
      System.assertEquals('relax.JobScheduler',jobs[0].Apex_Class__c);
      System.assertEquals(true,jobs[0].IsActive__c);
      System.assertNotEquals(null,jobs[0].CronTriggerId__c);
      System.assertNotEquals(null,jobs[0].JobSchedulerId__c);
      System.assertNotEquals(null,jobs[0].Next_Run__c);
        
    }
}