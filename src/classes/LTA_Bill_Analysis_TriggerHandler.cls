/******************************************************************************************
 * Name: LTA_Bill_Analysis_TriggerHandler
 * @Overall Description: Trigger handler for the Bill Analysis creations and assignments.
 * Identifies Tier A, B and C users while assigning Due Dates.
 * 
 * @Change Version:        Developer:         Change Date:          Change Description:
 * ----------------------------------------------------------------------------------------
 * 1.0                       VENTAS            2020-08-04            Initial Creation
 *
 ******************************************************************************************
*/

public without sharing class LTA_Bill_Analysis_TriggerHandler {
    public static void Process(){
        if (trigger.isbefore && trigger.isInsert) {
            Set<Id> tierB_Ids = new Set<Id>();
           
            for(LTA_Bill_Analysis__c ba : (List<LTA_Bill_Analysis__c>) trigger.new){
                if(ba.Division_SME_Analysis__c != null){
                    tierB_Ids.add(ba.Division_SME_Analysis__c);
                }
            }
            
            if(!tierB_Ids.isEmpty()){
                Map<Id, LTA_Bill_Analysis__c> tierB_Map = new Map<Id, LTA_Bill_Analysis__c>([SELECT Id, Link_To_Bill__c, Link_To_Bill__r.Due_Date__c FROM LTA_Bill_Analysis__c WHERE Id IN :tierB_Ids]);
                
                for(LTA_Bill_Analysis__c tierC : (LTA_Bill_Analysis__c[]) trigger.new) {
                    if (tierB_Map.containsKey(tierC.Division_SME_Analysis__c)) {
                        LTA_Bill_Analysis__c tierB = tierB_Map.get(tierC.Division_SME_Analysis__c);
                        if (tierB.Link_To_Bill__c!=null) {
                            //OwnerId = ;
                            tierC.Review_Status__c = 'New';
                            tierC.Link_To_Bill__c = tierB.Link_To_Bill__c;
                            if (tierB.Link_To_Bill__r.Due_Date__c!=null) {
                                tierC.Due_Date__c = tierB.Link_To_Bill__r.Due_Date__c.addDays(LTA_ProcessTeliconImport.tierC_dueDays - LTA_ProcessTeliconImport.tierA_dueDays);
                            }
                        }
                    }
                }
            }
        }
    }
}