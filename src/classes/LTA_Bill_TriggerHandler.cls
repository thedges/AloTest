/******************************************************************************************
 * Name: LTA_Bill_TriggerHandler
 * @Overall Description: Keep due dates in sync with LTA_Bill_Analysis__c records when changed on an bill record
 *      When a new bill is inserted, link to the previous bill
 *      If 4 specific fields are populated, and LTA_Bill_Analysis__c records do not exist, generate LTA_Bill_Analysis__c records for the SLA, Primary and Corollary division users.
 * 
 * @Change Version:        Developer:         Change Date:          Change Description:
 * ----------------------------------------------------------------------------------------
 * 1.0                       VENTAS            2020-08-04            Initial Creation
 *
 ******************************************************************************************
*/

public without sharing class LTA_Bill_TriggerHandler {
    private static void updateDueDates(List<LTA_Bill__c> triggerNew, Map<Id,LTA_Bill__c> triggerOldMap){
        List<Id> ids = new List<Id>();
        for(LTA_Bill__c bill : triggerNew){
            //if this is supposed to cover only due date changes, I think it should not execute if Due Date is changing from null to not null
            if(triggerOldMap.get(bill.Id).Due_Date__c != null && bill.Due_Date__c != triggerOldMap.get(bill.Id).Due_Date__c) {
                ids.add(bill.Id);
            }
        }
        
        if(!ids.isEmpty()) {
            List<LTA_Bill_Analysis__c> listUpdates = new List<LTA_Bill_Analysis__c>();
            for(LTA_Bill__c b : [SELECT Id, OwnerId, Legislative_Liaison_SLA__c, SLA_Analysis__c, Due_Date__c, (SELECT Id, OwnerId, Due_Date__c, Division_SME_Analysis__c FROM Bill_Analyses__r) FROM LTA_Bill__c WHERE Id IN :ids]) {
                if (!b.Bill_Analyses__r.isEmpty()) {
                    for(LTA_Bill_Analysis__c ba : b.Bill_Analyses__r) {
                        if(ba.OwnerId == b.Legislative_Liaison_SLA__c) //Tier A
                            ba.Due_Date__c = b.Due_Date__c;
                        else if(ba.OwnerId != b.Legislative_Liaison_SLA__c && ba.Division_SME_Analysis__c == null) //Tier B
                            ba.Due_Date__c = b.Due_Date__c.addDays(LTA_ProcessTeliconImport.tierB_dueDays - LTA_ProcessTeliconImport.tierA_dueDays);
                        else { //Tier C
                            ba.Due_Date__c = b.Due_Date__c.addDays(LTA_ProcessTeliconImport.tierC_dueDays - LTA_ProcessTeliconImport.tierA_dueDays);
                        }
                        listUpdates.add(ba);
                    }
                }
            }
           
            update listUpdates;
        }
    }

    private static void afterInsertUpdateHandler(){
        system.debug('BEGIN afterInsertUpdateHandler()');
        
        set<Id> parentIds = new set<Id>();
        List<LTA_Bill__c> billsToProcess = new List<LTA_Bill__c>();
        for(LTA_Bill__c bill : [SELECT Id, OwnerId, Parent__c, Primary_Division__c, Corollary_Division_s__c, Legislative_Liaison_SLA__c, SLA_Analysis__c, Due_Date__c, (SELECT Id, OwnerId, Owner.Username, Due_Date__c, Division_SME_Analysis__c FROM Bill_Analyses__r) FROM LTA_Bill__c WHERE Id IN :trigger.new]){
            //system.debug('Loop Bill: ' + bill);
            //system.debug('Bill.Bill_Analyses__r: ' + bill.Bill_Analyses__r);
            //system.debug('Bill.Bill_Analyses__r.isEmpty(): ' + bill.Bill_Analyses__r.isEmpty());
            if (bill.Bill_Analyses__r.isEmpty()) {
                billsToProcess.add(bill);
                if (bill.Parent__c!=null) {
                    parentIds.add(bill.Parent__c);
                }
            }
        }
        system.debug('parentIds: ' + parentIds);
        system.debug('billsToProcess: ' + billsToProcess);
        
        if (billsToProcess.isEmpty()) {
            system.debug('No bills to process...');
            return;
        }

        Set<String> divisionValues = new Set<String>();
        for(LTA_Bill__c bill : billsToProcess){
            if(bill.Primary_Division__c != null) {
                divisionValues.add(bill.Primary_Division__c);
            }
            if(bill.Corollary_Division_s__c != null) {
                for(String s : bill.Corollary_Division_s__c.split(';')){
                    if (!string.isBlank(s)) {
                        divisionValues.add(s.trim());
                    }
                }
            }
        }
        
        system.debug('divisionValues: ' + divisionValues);

        Map<String, List<User>> divisionToUserMap = new Map<String, List<User>>();
        for(User u : [SELECT Id, Division__c, Title__c FROM User WHERE IsActive=true AND Division__c IN :divisionValues]){
            if(!divisionToUserMap.containsKey(u.Division__c)) {
                divisionToUserMap.put(u.Division__c, new List<User>());
            }
            divisionToUserMap.get(u.Division__c).add(u);
        }

        Map<Id, LTA_Bill__c> previousBills = new Map<Id, LTA_Bill__c> ([SELECT Id, OwnerId, Primary_Division__c, Corollary_Division_s__c, Legislative_Liaison_SLA__c, SLA_Analysis__c, Due_Date__c, (SELECT Id, OwnerId, Owner.IsActive, Division_SME_Analysis__c FROM Bill_Analyses__r) FROM LTA_Bill__c WHERE Id IN :parentIds]);
        system.debug('previousBills: ' + previousBills);
        
        List<LTA_Bill_Analysis__c> basToInsert = new List<LTA_Bill_Analysis__c>();
        List<LTA_Bill_Analysis__c> tierCToInsert = new List<LTA_Bill_Analysis__c>();
        Map<Id, LTA_Bill_Analysis__c> billToSLAAnalysis = new Map<Id, LTA_Bill_Analysis__c>();
        for(LTA_Bill__c bill : billsToProcess){
            //system.debug('bill: ' + bill);
            if(bill.Corollary_Division_s__c != null && bill.Primary_Division__c != null && bill.Legislative_Liaison_SLA__c != null && bill.Due_Date__c!=null){
                Set<String> divisionsToProcess = new Set<String>();
                for(String s : bill.Corollary_Division_s__c.split(';')){
                    if (!string.isBlank(s)) {
                        divisionsToProcess.add(s.trim());
                    }
                }
                divisionsToProcess.add(bill.Primary_Division__c);
                //system.debug('divisionsToProcess: ' + divisionsToProcess);
                
                Map<Id, User> usersToProcess = new Map<Id, User>();
                for(String s : divisionsToProcess){
                    if (divisionToUserMap.containsKey(s)) {
                        //Add Tier-B users. NOTE: There is only 1 per division, but this should handle all for future changes.
                        for(User u : divisionToUserMap.get(s)) {
                            if (u.Title__c == 'Legislative Coordinator') {
                                //Only users w/ this title are Tier-B users.
                                usersToProcess.put(u.Id, u);
                            }
                        }
                    }
                }
                
                //Add the SLA user
                if (!usersToProcess.containsKey(bill.Legislative_Liaison_SLA__c)){
                    usersToProcess.put(bill.Legislative_Liaison_SLA__c, new User(Id = bill.Legislative_Liaison_SLA__c));
                }
                
                for(User u : usersToProcess.values()){
                    //system.debug('user: ' + u);
                    LTA_Bill_Analysis__c newBA = new LTA_Bill_Analysis__c(
                        OwnerId = u.Id,
                        Link_To_Bill__c = bill.Id,
                        Review_Status__c = 'New'
                    );
                    
                    if(u.Id == bill.Legislative_Liaison_SLA__c){
                        billToSLAAnalysis.put(bill.Id, newBA);
                        newBA.Due_Date__c = bill.Due_Date__c;
                    }
                    else {
                        newBA.Due_Date__c = bill.Due_Date__c.addDays(LTA_ProcessTeliconImport.tierB_dueDays - LTA_ProcessTeliconImport.tierA_dueDays);
                    }
                    
                    basToInsert.add(newBA);
                    
                    if (bill.Parent__c != null) {
                        //system.debug('bill.Parent__c: ' + bill.Parent__c);
                        
                        if (previousBills.containsKey(bill.Parent__c)){
                            LTA_Bill__c pb = previousBills.get(bill.Parent__c);
                            //system.debug('pb.Bill_Analyses__r: ' + pb.Bill_Analyses__r);

                            for(LTA_Bill_Analysis__c tierB : pb.Bill_Analyses__r) {
                                if (tierB.Division_SME_Analysis__c!=null) {
                                    //Skip tierB
                                    continue;
                                }
                                
                                if (u.Id != tierB.OwnerId) {
                                    continue;
                                }
                                
                                for(LTA_Bill_Analysis__c tierC : pb.Bill_Analyses__r) {
                                    if (tierC.Division_SME_Analysis__c == tierB.Id) {
                                        if (tierC.Owner.IsActive) {
                                            LTA_Bill_Analysis__c newTierCBA = new LTA_Bill_Analysis__c(
                                                OwnerId = tierC.OwnerId,
                                                Link_to_Bill__c = bill.Id,
                                                Review_Status__c = 'New',
                                                Due_Date__c = bill.Due_Date__c.addDays(LTA_ProcessTeliconImport.tierB_dueDays - LTA_ProcessTeliconImport.tierA_dueDays),
                                                Division_SME_Analysis__r = newBA
                                            );
                                            tierCToInsert.add(newTierCBA);
                                        }
                                        //continue in case there are duplicates...
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        insert basToInsert;

        for(LTA_Bill_Analysis__c ba : tierCToInsert){
            ba.Division_SME_Analysis__c = ba.Division_SME_Analysis__r.Id;
        } 
        insert tierCToInsert;

        //Link the SLA's Bill Analysis back to the parent Bill
        List<LTA_Bill__c> billsToUpdate = new List<LTA_Bill__c>();
        for(string key : billToSLAAnalysis.keySet()){
            billsToUpdate.add(new LTA_Bill__c(Id = key, SLA_Analysis__c = billToSLAAnalysis.get(key).Id));
        }        
        update billsToUpdate;
    }
    
    private static boolean lock = false;
    public static void Process(){
        system.debug('LTA_Bill_TriggerHandler Processing...');
        if (lock) {return;}
        if (trigger.isAfter) {
            if (trigger.isInsert){
                try{
                    lock = true;
                    afterInsertUpdateHandler();
                }
                finally {
                    lock = false;
                }
            }
            else if (trigger.isUpdate) {
                try{
                    lock = true;
                    updateDueDates((List<LTA_Bill__c>)trigger.New, (Map<ID, LTA_Bill__c>)trigger.OldMap);
                }
                finally {
                    lock = false;
                }
                try{
                    lock = true;
                    afterInsertUpdateHandler();
                }
                finally {
                    lock = false;
                }
            }
        }
    }
}