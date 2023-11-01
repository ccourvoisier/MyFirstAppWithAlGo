pageextension 50141 "EXOTEC JobLocationAllowEntry" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("EXOTEC Allow Unknown Job Entry"; Rec."EXOTEC Allow Unknown Job Entry")
            {
                Importance = Additional;
                ApplicationArea = All;
                ToolTip = 'This option allow unknow inventory job entry on the location';
            }
        }
    }
}