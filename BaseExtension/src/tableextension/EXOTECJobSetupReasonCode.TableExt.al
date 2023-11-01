tableextension 50142 "EXOTEC JobSetupReasonCode" extends "Jobs Setup"
{
    fields
    {
        field(50140; "EXOTEC Job Inv. Inb. Rea Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Job Inventory Inbound Reason Code';
            TableRelation = "Reason Code".Code;
            ValidateTableRelation = true;
        }
    }

}