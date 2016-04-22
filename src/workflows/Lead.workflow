<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_back_to_New</fullName>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>Update back to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update back to New status</fullName>
        <actions>
            <name>Update_back_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  IsConverted = FALSE,  ISPICKVAL( Status , &quot;Converted&quot;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
