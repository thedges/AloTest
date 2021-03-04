/*
 * Name: LTA_Bill_Analysis
 * @Description: Trigger handler for the Bill Analysis creations and assignments
 * @Date: 2020-08-04
 * @Author: VENTAS
*/

trigger LTA_Bill_Analysis on LTA_Bill_Analysis__c (before insert, before update) {
    LTA_Bill_Analysis_TriggerHandler.Process();
}