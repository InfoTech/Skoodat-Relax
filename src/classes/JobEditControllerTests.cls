@isTest
public class JobEditControllerTests
{
  private static testMethod void TestIndividuallyScheduledJob() {
  	// Load up our page for a new Job record
  	Job__c j = new Job__c();
  	ApexPages.Standardcontroller stdctl = new ApexPages.Standardcontroller(j);
  	JobEditController ctl = new JobEditController(stdctl);
  	Test.setCurrentPage(System.Page.EditJob);
  	System.assertEquals(false,ApexPages.hasMessages());
  	
  	// We should have non-null lists of schedulable and aggregable class options
  	List<ApexClass> classes = ctl.getAllApexClasses();
  	List<SelectOption> aggregables = ctl.getAsyncProcessStepClassOptions();
  	List<SelectOption> schedulables = ctl.getSchedulableClassOptions();
  	System.assertNotEquals(null,classes);
  	System.assertNotEquals(null,aggregables);
  	System.assertNotEquals(null,schedulables);
  	
  	// Schedule an individual job
  	j = ctl.job;
  	System.assertNotEquals(null,j);
  	j.Name = 'Unit_Test_Individually_Scheduled_Job';
  	j.Run_Individually__c = true;
  	j.IsActive__c = true;
  	j.Cron_Schedule__c = '0 0 13 * * ?' ;
  	
  	ctl.schedulableClassName = null;
  	PageReference p = ctl.save();
  	
  	// We should have an error
  	System.assertEquals(true,ApexPages.hasMessages());
  	
  	// Reschedule our record, this time specifying a valid schedulable class
  	ctl.schedulableClassName = 'relax.JobScheduler';
  	p = ctl.save();
  	
  	System.assert(p.getURL().contains('/'+Job__c.SObjectType.getDescribe().getKeyPrefix()));
  	
  	// Verify that our record saved
  	List<Job__c> jobs = [
  		select	Id, Apex_Class__c, IsActive__c, CronTriggerId__c, JobSchedulerId__c, Next_Run__c
  		from	Job__c
  		where	Name = 'Unit_Test_Individually_Scheduled_Job' 
  		order by CreatedDate DESC limit 1
  	];
  	System.assertEquals(1,jobs.size());
  	System.assertEquals('relax.JobScheduler',jobs[0].Apex_Class__c);
  	System.assertEquals(true,jobs[0].IsActive__c);
  	System.assertNotEquals(null,jobs[0].CronTriggerId__c);
  	System.assertNotEquals(null,jobs[0].JobSchedulerId__c);
  	System.assertNotEquals(null,jobs[0].Next_Run__c);
  	
  	// Cancel
  	System.assert(ctl.cancel().getURL().contains('/'+Job__c.SObjectType.getDescribe().getKeyPrefix()));
  }
    
  private static testMethod void TestAggregableJob() 
  {
		// Load up our page for a new Job record
		Job__c j = new Job__c();
		ApexPages.Standardcontroller stdctl = new ApexPages.Standardcontroller(j);
		JobEditController ctl = new JobEditController(stdctl);
		Test.setCurrentPage(System.Page.EditJob);
		System.assertEquals(false,ApexPages.hasMessages());

		// We should have non-null lists of schedulable and aggregable class options
		List<SelectOption> aggregables = ctl.getAsyncProcessStepClassOptions();
		System.assertNotEquals(null,aggregables);

		// Schedule an aggregable job --- we should get an error because no class has been specified
		j = ctl.job;
		System.assertNotEquals(null,j);
		j.Name = 'Unit_Test_Aggregable_Job';
		j.Run_Individually__c = false;
		j.IsActive__c = true;
		j.Run_Increment__c = 1;
		j.Run_Units__c = 'Minutes';
		ctl.asyncProcessStepClassName = null;
		PageReference p = ctl.save();

		// We should have an error
		System.assertEquals(true,ApexPages.hasMessages());

		// Try to create our job again after specifying a valid class name
		ctl.asyncProcessStepClassName = 'relax.BatchAccountsUpdater';
		p = ctl.save();

		// Verify that our record saved
		List<Job__c> jobs = [
			select	Id, Apex_Class__c, IsActive__c, JobSchedulerId__c, Next_Run__c
			from	Job__c
			where	Name = 'Unit_Test_Aggregable_Job' 
			order by CreatedDate DESC limit 1
		];
		System.assertEquals(1,jobs.size());
		System.assertEquals('relax.BatchAccountsUpdater',jobs[0].Apex_Class__c);
		System.assertEquals(true,jobs[0].IsActive__c);
		System.assertNotEquals(null,jobs[0].JobSchedulerId__c);
		System.assertNotEquals(null,jobs[0].Next_Run__c);
  }
}