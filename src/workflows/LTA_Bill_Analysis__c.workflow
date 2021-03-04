<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LTA_Bill_Analysis_Marked_for_Deletion</fullName>
        <description>LTA - Bill Analysis Marked for Deletion</description>
        <protected>false</protected>
        <recipients>
            <recipient>LTA_Government_Affairs</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LTA_Bill_Email_Templates/LTA_Bill_Analysis_Marked_for_Deletion</template>
    </alerts>
    <alerts>
        <fullName>LTA_Fiscal_Impact_Statement_Request_Email_Alert_for_the_Divisions</fullName>
        <description>LTA - Fiscal Impact Statement Request Email Alert for the Divisions</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LTA_Bill_Email_Templates/LTA_Fiscal_Impact_Statement_Requested</template>
    </alerts>
</Workflow>
