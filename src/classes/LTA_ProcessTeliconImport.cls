/******************************************************************************************
 * Name: LTA_ProcessTeliconImport
 * @Overall Description: Batch data load process and mapping for data from Telicon into LTA_BillImport__c object. 
 *  This process loads the raw data into the LTA_BillImport__c object then identifies the specific TxDOT LTA versions 
 *  and automatically maps into the LTA_Bill__c object while carrying over previous data points if a new Bill Version 
 *  is loaded and automatically assigning associated Due Dates.
 * 
 * @Change Version:        Developer:         Change Date:          Change Description:
 * ----------------------------------------------------------------------------------------
 * 1.0                       VENTAS            2020-08-04             Initial Creation
 *
 ******************************************************************************************
*/
public without sharing class LTA_ProcessTeliconImport implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static final integer tierA_dueDays = 7;
    public static final integer tierB_dueDays = 5;
    public static final integer tierC_dueDays = 3;

    private final DateTime batchTimeStamp = DateTime.now(); //Use this GMT timstamp for marking processed records w/ same exact value
    private final Date batchToday = Date.today();

    public void execute(SchedulableContext sc) {
        start();
    }
    
    public static void start() {
        start(100);
    }
    
    public static void start(integer batchSize) {
        database.executeBatch(new LTA_ProcessTeliconImport(), batchSize);
    }

    public LTA_ProcessTeliconImport() {

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT
                Id,
                OwnerId,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                Bill_State__c,
                Bill_Session__c,
                Bill_Type__c,
                Bill_Number__c,
                Bill__c,
                Bill_Author__c,
                Bill_Caption__c,
                Bill_f__c,
                Last_Action__c,
                CB1_State__c,
                CB2_State__c,
                CB3_State__c,
                CB1_Session__c,
                CB2_Session__c,
                CB3_Session__c,
                CB1_Type__c,
                CB2_Type__c,
                CB3_Type__c,
                CB1_Number__c,
                CB2_Number__c,
                CB3_Number__c,
                CB1_f__c,
                CB2_f__c,
                CB3_f__c,
                Processed__c,
                Link__c,
                FIL__c,
                HCA__c,
                HCS__c,
                HFN__c,
                HBA__c,
                HPA__c,
                HFA__c,
                ENG__c,
                SCA__c,
                SCS__c,
                SFN__c,
                SBA__c,
                SPA__c,
                SFA__c,
                CCR__c,
                FBA__c,
                FFN__c,
                ENR__c,
                VET__c
                FROM
                    LTA_BillImport__c
                WHERE
                    Processed__c=null
                ORDER BY CreatedDate ASC
        ]);
    }

    public void execute(Database.BatchableContext BC, List<LTA_BillImport__c> scope) {
        Set<String> teliconIds = new Set<String>();
        for(LTA_BillImport__c bi : scope){
            teliconIds.add(bi.Bill__c);
        }
        
        Map<String, LTA_Bill__c> extIdToBillMap = new Map<String, LTA_Bill__c>();
        for(LTA_Bill__c bill : [
            SELECT  Id,
            Bill_Version__c,
            Telicon_Bill_ID__c,
            Subject__c,
            Impact__c,
            Corollary_Division_s__c,
            Legislative_Liaison_SLA__c, 
            Primary_Division__c
            FROM    LTA_Bill__c
            WHERE   Telicon_Bill_ID__c in :teliconIds]){
                extIdToBillMap.put(bill.Telicon_Bill_ID__c, bill);
            }
        
        system.debug('extIdToBillMap: ' + extIdToBillMap);
        
        List<Schema.PicklistEntry> plList = LTA_Bill__c.Bill_Version__c.getDescribe().getPicklistValues();
        system.debug('plList: ' + plList);
        
        Map<string, LTA_Bill__c> billsToInsert = new Map<string, LTA_Bill__c>();
        for(LTA_BillImport__c bi : scope){
            bi.Processed__c = batchTimeStamp; //Tag this as processed

            LTA_Bill__c newBill = new LTA_Bill__c();
            
            newBill.Name = bi.Bill_Type__c + bi.Bill_Number__c.leftPad(5, '0');
            newBill.Bill_Number__c = bi.Bill_Number__c;
            newBill.Bill_Session__c = bi.Bill_Session__c;
            newBill.Bill_Type__c = bi.Bill_Type__c;
            newBill.Bill_Author__c = bi.Bill_Author__c;
            newBill.Bill_Caption__c = bi.Bill_Caption__c;
            newBill.CB1Name__c = bi.CB1_f__c;
            newBill.CB2Name__c = bi.CB2_f__c;
            newBill.CB3Name__c = bi.CB3_f__c;
            newBill.Last_Action__c = bi.Last_Action__c;
            newBill.Link__c = bi.Link__c;
            newBill.Telicon_Bill_ID__c = bi.Bill__c;
            newBill.Bill_Version__c = null;
            newBill.Due_Date__c = batchToday.addDays(tierA_dueDays);
            
            //Identify the version based on field populated
            for (integer i = plList.size()-1; i >= 0; i--){
                string api = plList[i].getValue();
                //system.debug('picklist value list item: ' + api);
                
                string fieldName = api + '__c';
                
                try {
                    string v = (string) bi.get(fieldName);
                    if (!string.isBlank(v)) {
                        newBill.Bill_Version__c = api;
                        break;
                    }
                }
                catch(Exception ex){
                    system.debug('Error getting field [' + fieldName + ']: ' + ex.getMessage());
                }
            }
            
            if (extIdToBillMap.containsKey(bi.Bill__c)) {
                LTA_Bill__c oldBill = extIdToBillMap.get(bi.Bill__c);
                if (newBill.Bill_Version__c == oldBill.Bill_Version__c){
                    continue; //Skip this bill, nothing to do!
                }
                
                newBill.Parent__c = oldBill.Id;

                //Per requirement, carry these over from the original bill
                newBill.Legislative_Liaison_SLA__c = oldBill.Legislative_Liaison_SLA__c;
                newBill.Primary_Division__c = oldBill.Primary_Division__c;
                newBill.Corollary_Division_s__c = oldBill.Corollary_Division_s__c;
                newBill.Impact__c = oldBill.Impact__c;
                newBill.Subject__c = oldBill.Subject__c;
            }

            //Since we process older records first, this will overwrite any existing w/ latest here to prevent insert/update issues
            billsToInsert.put(newBill.Telicon_Bill_ID__c, newBill);
        }

        system.debug('billsToInsert: ' + billsToInsert);
        system.debug('billsToInsert.size(): ' + billsToInsert.size());

        List<LTA_Bill__c> billsToUpdate = new List<LTA_Bill__c>();
        for(LTA_Bill__c bill : billsToInsert.values()){
            if(extIdToBillMap.get(bill.Telicon_Bill_ID__c) != null){
                //Removing ExternalId from existing records
                billsToUpdate.add(new LTA_Bill__c(Id = extIdToBillMap.get(bill.Telicon_Bill_ID__c).Id,  Telicon_Bill_ID__c = null));
            }
        }

        SavePoint sp = database.setSavepoint();
        try{
            system.debug('billsToUpdate: ' + billsToUpdate);
            system.debug('billsToUpdate.size(): ' + billsToUpdate.size());
            update billsToUpdate;
    
            system.debug('billsToInsert: ' + billsToInsert);
            insert billsToInsert.values();
    
            system.debug('scope: ' + scope);
            update scope;
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
            database.rollback(sp);
            throw ex;
        }
    }

    public void finish(Database.BatchableContext BC) { }
}