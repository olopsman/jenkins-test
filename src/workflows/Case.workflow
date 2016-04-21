<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Update_Cancellation_Date_c</fullName>
        <field>Cancellation_Date__c</field>
        <formula>today()</formula>
        <name>Case: Update Cancellation_Date__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Cancellation Date Default</fullName>
        <actions>
            <name>Case_Update_Cancellation_Date_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Cancellation date defaults to current date when Cancellation_Date__c is left blank upon save.</description>
        <formula>ISBLANK( Cancellation_Date__c ) &amp;&amp; 
RecordType.Name = &quot;Cancellation&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
