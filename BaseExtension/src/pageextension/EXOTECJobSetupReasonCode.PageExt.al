pageextension 50142 "EXOTEC JobSetupReasonCode" extends "Jobs Setup"
{
    layout
    {
        addlast(General)
        {
            field("EXOTEC Job Inv. Inb. Rea Code"; Rec."EXOTEC Job Inv. Inb. Rea Code")
            {
                Importance = Additional;
                ApplicationArea = All;
                ToolTip = 'This is the default reason code if the reason code is not filled on job inventory inbound';
            }
        }
    }

}