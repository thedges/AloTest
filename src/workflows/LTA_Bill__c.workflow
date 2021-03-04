<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LTA_Fiscal_Impact_Statement_Request_Email_Alert_for_the_SLA</fullName>
        <description>LTA - Fiscal Impact Statement Request Email Alert for the SLA</description>
        <protected>false</protected>
        <recipients>
            <field>Legislative_Liaison_SLA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LTA_Bill_Email_Templates/LTA_Fiscal_Impact_Statement_Requested</template>
    </alerts>
</Workflow>
