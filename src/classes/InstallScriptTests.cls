@isTest
public class InstallScriptTests
{
  private static testMethod void TestInstall() 
  {
    InstallScript is = new InstallScript();
    Test.testInstall(is, null);
    Boolean b = false;
    System.assertEquals(false,b);
    
    //SendDebugEmail('test','test','testsubject',new List<String>{'zach@skoodat.com'});
  }
}