//
// Controller for EditJob page
//

public with sharing class JobEditController {

    public Job__c job { public get; private set; }
    public String schedulableClassName { 
        public get; 
        public set {
            schedulableClassName = value;
            if (job.Run_Individually__c) {
            	job.Apex_Class__c = value;
            }	
        }
    }
    public String asyncProcessStepClassName { 
        public get; 
        public set {
            asyncProcessStepClassName = value;
            if (!job.Run_Individually__c) {
            	job.Apex_Class__c = value;
            }
        }
    }

    public JobEditController(ApexPages.StandardController ctl) {
        job = (Job__c) ctl.getRecord();
        getSchedulableClassOptions();
        getAsyncProcessStepClassOptions();
        
        if (!schedulableClassOptions.isEmpty()) {
        	// Are we updating an existing INDIVIDUALLY-scheduled Job?
        	// If so, attempt to find that job in our list of options.
        	if (job.Run_Individually__c && (job.Apex_Class__c != null)) {
        		schedulableClassName = job.Apex_Class__c;
        	} else {
        		schedulableClassName = schedulableClassOptions[0].getValue();
        	}
        }
        if (!asyncProcessStepClassOptions.isEmpty()) {
            // Are we updating an existing AGGREGABLE Job?
        	// If so, attempt to find that job in our list of options.
        	if (!job.Run_Individually__c && (job.Apex_Class__c != null)) {
        		asyncProcessStepClassName = job.Apex_Class__c;
        	} else {
        		asyncProcessStepClassName = asyncProcessStepClassOptions[0].getValue();
        	}   
        }
    }
    
    // On Save, send the user to the Tab for Jobs
    public PageReference save() {
    	try {
    		upsert job;
    		return cancel();
    	} catch (Exception ex) {
    		ApexPages.addMessages(ex);
    	}
    	return null;
    }
    
    // On Save, send the user to the Tab for Jobs
    public PageReference cancel() {
    	return new PageReference('/' + Job__c.SObjectType.getDescribe().getKeyPrefix());
    }
     
    
    // Return a list of all Apex class choices 
    private transient List<ApexClass> allApexClasses;
    public List<ApexClass> getAllApexClasses() {    
        if (allApexClasses == null) {
        	allApexClasses = new List<ApexClass>();
        	for (List<ApexClass> classes : [select Name, NamespacePrefix from ApexClass]) {
        		allApexClasses.addAll(classes);
        	}
        }
        return allApexClasses;
    }
    
    private transient List<SelectOption> schedulableClassOptions; 
    
    // Returns a list of all Schedulable Apex Classes
    public List<SelectOption> getSchedulableClassOptions() {    
        if (schedulableClassOptions == null) {
            schedulableClassOptions = buildSchedulableClassOptions();
        }
        return schedulableClassOptions;
    }
    
    // Build a list of all schedulable class options
    private List<SelectOption> buildSchedulableClassOptions() {
    
        List<SelectOption> options = new List<SelectOption>();
    
        // Build a list of Schedulable classes, so that we can sort
        Map<String,ApexClass> schedulableClasses = new Map<String,ApexClass>();
    
        // Loop over our Apex classes, seeing if they are Schedulable
        for (ApexClass cls : getAllApexClasses()) {
            System.Type t;
            try {
                t = System.Type.forName(cls.NamespacePrefix,cls.Name);
            } catch (Exception ex) { continue; }
            Schedulable s;
            try {
                s = (Schedulable) JSON.deserialize('{}',t);
            } catch (Exception ex) { continue; }
            if (s != null) {
                schedulableClasses.put(cls.Name,cls);
            }    
        }
        
        if (!schedulableClasses.isEmpty()) {
            // Sort our class names alphabetically
            List<String> names = new List<String>();
            names.addAll(schedulableClasses.keyset());
            names.sort();
            for (String s : names) {
                ApexClass cls = schedulableClasses.get(s);
                options.add(new SelectOption(
                    // Value --- add in the namespace prefix if it exists
                    ((cls.NamespacePrefix != null) ? cls.NamespacePrefix + '.' : '') + s,
                    // Label
                    s + ((cls.NamespacePrefix != null) ? ' (' + cls.NamespacePrefix + ')' : '')
                ));
            }
        }
        
        return options;
        
    }
    
    // Returns a list of all classes implementing ProcessStep
    private transient List<SelectOption> asyncProcessStepClassOptions; 
    public List<SelectOption> getAsyncProcessStepClassOptions() {    
        if (asyncProcessStepClassOptions == null) {
            asyncProcessStepClassOptions = buildAsyncProcessStepClassOptions();
        }
        return asyncProcessStepClassOptions;
    }
    
    
    // Build a list of all classes that implement ProcessStep
    private List<SelectOption> buildAsyncProcessStepClassOptions() {
    
        List<SelectOption> options = new List<SelectOption>();
    
        // Build a map of classes, so that we can sort
        Map<String,ApexClass> classes = new Map<String,ApexClass>();
    
        // Loop over our Apex classes, seeing if they are Schedulable
        for (ApexClass cls : getAllApexClasses()) {
        	// Ignore our abstract implementations
            if (!cls.Name.toLowerCase().contains('processstep')) {
	        	
	            System.Type t;
	            try {
	                t = System.Type.forName(cls.NamespacePrefix,cls.Name);
	            } catch (Exception ex) { continue; }
	            ProcessStep s;
	            try {
	                s = (ProcessStep) JSON.deserialize('{}',t);
	            } catch (Exception ex) { continue; }
	            if (s != null) {
	                classes.put(cls.Name,cls);
	            }
            }    
        }
        
        if (!classes.isEmpty()) {
            // Sort our class names alphabetically
            List<String> names = new List<String>();
            names.addAll(classes.keyset());
            names.sort();
            for (String s : names) {
                ApexClass cls = classes.get(s);
                options.add(new SelectOption(
                    // Value --- add in the namespace prefix if it exists
                    ((cls.NamespacePrefix != null) ? cls.NamespacePrefix + '.' : '') + s,
                    // Label
                    s + ((cls.NamespacePrefix != null) ? ' (' + cls.NamespacePrefix + ')' : '')
                ));
            }
        }
        
        return options;
        
    }

}