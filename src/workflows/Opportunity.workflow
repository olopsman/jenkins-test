<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_back_to_Opportunity</fullName>
        <field>StageName</field>
        <literalValue>Opportunity</literalValue>
        <name>Set back to Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Opportunity</fullName>
        <actions>
            <name>Set_back_to_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISPICKVAL(StageName,&quot;Qualified Opportunity&quot;), PRIORVALUE( DM_Assessment_Count__c ) = 20 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
