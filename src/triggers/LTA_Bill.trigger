/*
 * Name: LTA_Bill
 * @Description: Trigger handler for the Bill updates and clone process for new bill verions
 * @Date: 2020-08-04
 * @Author: VENTAS
*/

trigger LTA_Bill on LTA_Bill__c (after insert, after update) {
    LTA_Bill_TriggerHandler.Process();
}