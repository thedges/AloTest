/******************************************************************************************
 * Name: LTA_Bill_UnitTests
 * @Overall Description: Unit tests for the Bill Import/Processing
 * 
 * @Change Version:        Developer:         Change Date:          Change Description:
 * ----------------------------------------------------------------------------------------
 * 1.0                       VENTAS            2020-08-04             Initial Creation
 *
 ******************************************************************************************
*/
@isTest public class LTA_Bill_UnitTests {
    @isTest
    public static void testTier3() {
        LTA_ProcessTeliconImport batchClass = new LTA_ProcessTeliconImport();

        LTA_BillImport__c b = new LTA_BillImport__c();
        b.Bill__c                    ='TX86RHB00001';
        b.Bill_State__c              ='TX';
        b.Bill_Session__c            ='86R';
        b.Bill_Type__c               ='HB ';
        b.Bill_Number__c             ='1    ';
        b.Bill_Author__c             ='Zerwas, John';
        b.Bill_Caption__c            ='General Appropriations Bill.';
        b.CB1_State__c               ='  ';
        b.CB1_Session__c             ='   ';
        b.CB1_Type__c                ='   ';
        b.CB1_Number__c              ='     ';
        b.CB2_State__c               ='  ';
        b.CB2_Session__c             ='   ';
        b.CB2_Type__c                ='   ';
        b.CB2_Number__c              ='     ';
        b.CB3_State__c               ='  ';
        b.CB3_Session__c             ='   ';
        b.CB3_Type__c                ='   ';
        b.CB3_Number__c              ='     ';
        b.FIL__c                     ='20190123';
        b.HCA__c                     ='        ';
        b.HCS__c                     ='        ';
        b.HFN__c                     ='        ';
        b.HBA__c                     ='        ';
        b.HPA__c                     ='        ';
        b.HFA__c                     ='        ';
        b.ENG__c                     ='        ';
        b.SCA__c                     ='        ';
        b.SCS__c                     ='        ';
        b.SFN__c                     ='        ';
        b.SBA__c                     ='        ';
        b.SPA__c                     ='        ';
        b.SFA__c                     ='        ';
        b.CCR__c                     ='        ';
        b.FBA__c                     ='        ';
        b.FFN__c                     ='        ';
        b.ENR__c                     ='        ';
        b.VET__c                     ='        ';
        b.Last_Action__c             ='09-01-19 G Earliest effective date';
        b.Link__c                    ='https://www.telicon.com/htbin/dil_bill?0120980TX86RHB00001';
        insert b;
        
        test.startTest();
            LTA_ProcessTeliconImport.start();
        test.stopTest();
        
        LTA_Bill__c bill = [SELECT ID, Due_Date__c, Subject__c, Impact__c, Legislative_Liaison_SLA__c, Primary_Division__c, Corollary_Division_s__c FROM LTA_Bill__c WHERE Telicon_Bill_ID__c = :b.Bill__c];
        
        bill.Due_Date__c = date.today().AddDays(5); //Change due date for more coverage
        bill.Subject__c = 'Appropriations';
        bill.Impact__c = '3 - Low';
        bill.Legislative_Liaison_SLA__c = [SELECT Id FROM User WHERE Username='dne3@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com'].Id;
        bill.Primary_Division__c = 'AUD';
        bill.Corollary_Division_s__c = 'AVN';
        update bill;
        
        LTA_Bill_Analysis__c tier3 = new LTA_Bill_Analysis__c();
        tier3.Division_SME_Analysis__c = [SELECT Id FROM LTA_Bill_Analysis__c WHERE Division_SME_Analysis__c=null LIMIT 1].Id;
        tier3.OwnerId = [SELECT Id FROM User WHERE Username='dne4@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com'].Id;
        insert tier3;
        
        tier3 = [SELECT Id, Division_SME_Analysis__c, OwnerId, Owner.IsActive, Link_To_Bill__c FROM LTA_Bill_Analysis__c WHERE Id = :tier3.Id];
        system.debug(tier3);
        system.debug(tier3.Owner);
    }

    @isTest
    public static void test1() {
        LTA_ProcessTeliconImport batchClass = new LTA_ProcessTeliconImport();

        LTA_BillImport__c b = new LTA_BillImport__c();
        b.Bill__c                    ='TX86RHB00001';
        b.Bill_State__c              ='TX';
        b.Bill_Session__c            ='86R';
        b.Bill_Type__c               ='HB ';
        b.Bill_Number__c             ='1    ';
        b.Bill_Author__c             ='Zerwas, John';
        b.Bill_Caption__c            ='General Appropriations Bill.';
        b.CB1_State__c               ='  ';
        b.CB1_Session__c             ='   ';
        b.CB1_Type__c                ='   ';
        b.CB1_Number__c              ='     ';
        b.CB2_State__c               ='  ';
        b.CB2_Session__c             ='   ';
        b.CB2_Type__c                ='   ';
        b.CB2_Number__c              ='     ';
        b.CB3_State__c               ='  ';
        b.CB3_Session__c             ='   ';
        b.CB3_Type__c                ='   ';
        b.CB3_Number__c              ='     ';
        b.FIL__c                     ='20190123';
        b.HCA__c                     ='        ';
        b.HCS__c                     ='        ';
        b.HFN__c                     ='        ';
        b.HBA__c                     ='        ';
        b.HPA__c                     ='        ';
        b.HFA__c                     ='        ';
        b.ENG__c                     ='        ';
        b.SCA__c                     ='        ';
        b.SCS__c                     ='        ';
        b.SFN__c                     ='        ';
        b.SBA__c                     ='        ';
        b.SPA__c                     ='        ';
        b.SFA__c                     ='        ';
        b.CCR__c                     ='        ';
        b.FBA__c                     ='        ';
        b.FFN__c                     ='        ';
        b.ENR__c                     ='        ';
        b.VET__c                     ='        ';
        b.Last_Action__c             ='09-01-19 G Earliest effective date';
        b.Link__c                    ='https://www.telicon.com/htbin/dil_bill?0120980TX86RHB00001';
        insert b;
        
        test.startTest();
            LTA_ProcessTeliconImport.start();
        test.stopTest();
        
        LTA_Bill__c bill = [SELECT ID, Due_Date__c, Subject__c, Impact__c, Legislative_Liaison_SLA__c, Primary_Division__c, Corollary_Division_s__c FROM LTA_Bill__c WHERE Telicon_Bill_ID__c = :b.Bill__c];
        
        bill.Due_Date__c = date.today().AddDays(5); //Change due date for more coverage
        bill.Subject__c = 'Appropriations';
        bill.Impact__c = '3 - Low';
        bill.Legislative_Liaison_SLA__c = [SELECT Id FROM User WHERE Username='dne3@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com'].Id;
        bill.Primary_Division__c = 'AUD';
        bill.Corollary_Division_s__c = 'AVN';
        update bill;
        
        LTA_Bill_Analysis__c tier3 = new LTA_Bill_Analysis__c();
        tier3.Division_SME_Analysis__c = [SELECT Id FROM LTA_Bill_Analysis__c WHERE Division_SME_Analysis__c=null LIMIT 1].Id;
        tier3.OwnerId = [SELECT Id FROM User WHERE Username='dne4@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com'].Id;
        insert tier3;

        b.Id = null; //Process same data...
        insert b;
        //Manually call batch methods this round...
        batchClass.execute(null, [SELECT Id, OwnerId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Bill_State__c, Bill_Session__c, Bill_Type__c, Bill_Number__c, Bill__c, Bill_Author__c, Bill_Caption__c, Bill_f__c, Last_Action__c, CB1_State__c, CB2_State__c, CB3_State__c, CB1_Session__c, CB2_Session__c, CB3_Session__c, CB1_Type__c, CB2_Type__c, CB3_Type__c, CB1_Number__c, CB2_Number__c, CB3_Number__c, CB1_f__c, CB2_f__c, CB3_f__c, Processed__c, Link__c, FIL__c, HCA__c, HCS__c, HFN__c, HBA__c, HPA__c, HFA__c, ENG__c, SCA__c, SCS__c, SFN__c, SBA__c, SPA__c, SFA__c, CCR__c, FBA__c, FFN__c, ENR__c, VET__c FROM LTA_BillImport__c WHERE Processed__c=null ORDER BY CreatedDate ASC]);

        
        b = new LTA_BillImport__c();
        b.Bill__c                    ='TX86RHB00001';
        b.Bill_State__c              ='TX';
        b.Bill_Session__c            ='86R';
        b.Bill_Type__c               ='HB ';
        b.Bill_Number__c             ='1    ';
        b.Bill_Author__c             ='Zerwas, John';
        b.Bill_Caption__c            ='General Appropriations Bill.';
        b.CB1_State__c               ='  ';
        b.CB1_Session__c             ='   ';
        b.CB1_Type__c                ='   ';
        b.CB1_Number__c              ='     ';
        b.CB2_State__c               ='  ';
        b.CB2_Session__c             ='   ';
        b.CB2_Type__c                ='   ';
        b.CB2_Number__c              ='     ';
        b.CB3_State__c               ='  ';
        b.CB3_Session__c             ='   ';
        b.CB3_Type__c                ='   ';
        b.CB3_Number__c              ='     ';
        b.FIL__c                     ='20190123';
        b.HCA__c                     ='        ';
        b.HCS__c                     ='20190318';
        b.HFN__c                     ='        ';
        b.HBA__c                     ='        ';
        b.HPA__c                     ='        ';
        b.HFA__c                     ='        ';
        b.ENG__c                     ='        ';
        b.SCA__c                     ='        ';
        b.SCS__c                     ='        ';
        b.SFN__c                     ='        ';
        b.SBA__c                     ='        ';
        b.SPA__c                     ='        ';
        b.SFA__c                     ='        ';
        b.CCR__c                     ='        ';
        b.FBA__c                     ='        ';
        b.FFN__c                     ='        ';
        b.ENR__c                     ='        ';
        b.VET__c                     ='        ';
        b.Last_Action__c             ='09-01-19 G Earliest effective date';
        b.Link__c                    ='https://www.telicon.com/htbin/dil_bill?0120980TX86RHB00001';
        insert b;
        
        //Manually call batch methods this round...
        batchClass.execute(null, [SELECT Id, OwnerId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Bill_State__c, Bill_Session__c, Bill_Type__c, Bill_Number__c, Bill__c, Bill_Author__c, Bill_Caption__c, Bill_f__c, Last_Action__c, CB1_State__c, CB2_State__c, CB3_State__c, CB1_Session__c, CB2_Session__c, CB3_Session__c, CB1_Type__c, CB2_Type__c, CB3_Type__c, CB1_Number__c, CB2_Number__c, CB3_Number__c, CB1_f__c, CB2_f__c, CB3_f__c, Processed__c, Link__c, FIL__c, HCA__c, HCS__c, HFN__c, HBA__c, HPA__c, HFA__c, ENG__c, SCA__c, SCS__c, SFN__c, SBA__c, SPA__c, SFA__c, CCR__c, FBA__c, FFN__c, ENR__c, VET__c FROM LTA_BillImport__c WHERE Processed__c=null ORDER BY CreatedDate ASC]);
        
        bill.Due_Date__c = date.today().AddDays(15); //Change due date for more coverage
        update bill;

        b = new LTA_BillImport__c();
        b.Bill__c                    ='TX86RHB00001';
        b.Bill_State__c              ='TX';
        b.Bill_Session__c            ='86R';
        b.Bill_Type__c               ='HB ';
        b.Bill_Number__c             ='1    ';
        b.Bill_Author__c             ='Zerwas, John';
        b.Bill_Caption__c            ='General Appropriations Bill.';
        b.CB1_State__c               ='  ';
        b.CB1_Session__c             ='   ';
        b.CB1_Type__c                ='   ';
        b.CB1_Number__c              ='     ';
        b.CB2_State__c               ='  ';
        b.CB2_Session__c             ='   ';
        b.CB2_Type__c                ='   ';
        b.CB2_Number__c              ='     ';
        b.CB3_State__c               ='  ';
        b.CB3_Session__c             ='   ';
        b.CB3_Type__c                ='   ';
        b.CB3_Number__c              ='     ';
        b.FIL__c                     ='20190123';
        b.HCA__c                     ='        ';
        b.HCS__c                     ='20190318';
        b.HFN__c                     ='        ';
        b.HBA__c                     ='        ';
        b.HPA__c                     ='        ';
        b.HFA__c                     ='20190327';
        b.ENG__c                     ='20190328';
        b.SCA__c                     ='        ';
        b.SCS__c                     ='20190403';
        b.SFN__c                     ='        ';
        b.SBA__c                     ='        ';
        b.SPA__c                     ='        ';
        b.SFA__c                     ='        ';
        b.CCR__c                     ='20190525';
        b.FBA__c                     ='        ';
        b.FFN__c                     ='        ';
        b.ENR__c                     ='20190527';
        b.VET__c                     ='        ';
        b.Last_Action__c             ='09-01-19 G Earliest effective date';
        b.Link__c                    ='https://www.telicon.com/htbin/dil_bill?0120980TX86RHB00001';
        insert b;

        //Manually call batch methods this round...
        batchClass.execute(null, [SELECT Id, OwnerId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Bill_State__c, Bill_Session__c, Bill_Type__c, Bill_Number__c, Bill__c, Bill_Author__c, Bill_Caption__c, Bill_f__c, Last_Action__c, CB1_State__c, CB2_State__c, CB3_State__c, CB1_Session__c, CB2_Session__c, CB3_Session__c, CB1_Type__c, CB2_Type__c, CB3_Type__c, CB1_Number__c, CB2_Number__c, CB3_Number__c, CB1_f__c, CB2_f__c, CB3_f__c, Processed__c, Link__c, FIL__c, HCA__c, HCS__c, HFN__c, HBA__c, HPA__c, HFA__c, ENG__c, SCA__c, SCS__c, SFN__c, SBA__c, SPA__c, SFA__c, CCR__c, FBA__c, FFN__c, ENR__c, VET__c FROM LTA_BillImport__c WHERE Processed__c=null ORDER BY CreatedDate ASC]);
    }

    @testsetup
    public static void setupTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TxDOT Basic Profile'];
        
        List<User> users = new List<User>();
        User u = new User();
        u.Division__c = 'AUD';
        u.LastName = 'XXX';
        u.Username = 'dne1@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com';
        u.Email = 'test@testing.com';
        u.Alias = '123124';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey ='America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.IsActive = true;
        u.Title__c = 'Legislative Coordinator';
        users.add(u);

        u = new User();        
        u.Division__c = 'AVN';
        u.LastName = 'XXX';
        u.Username = 'dne2@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com';
        u.Email = 'test@testing.com';
        u.Alias = '123124';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey ='America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.IsActive = true;
        u.Title__c = 'Legislative Coordinator';
        users.add(u);
        
        u = new User();
        u.Division__c = 'SLA';
        u.LastName = 'XXX';
        u.Username = 'dne3@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com';
        u.Email = 'test@testing.com';
        u.Alias = '123124';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey ='America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.IsActive = true;
        users.add(u);

        u = new User();
        u.Division__c = 'ITD';
        u.LastName = 'XXX';
        u.Username = 'dne4@lsadjkhfladsjkhflsadhflsadjkhfalsdjkfhalsdjkhasdf.com';
        u.Email = 'test@testing.com';
        u.Alias = '123124';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey ='America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.IsActive = true;
        users.add(u);
        
        insert users;
        
    }
}