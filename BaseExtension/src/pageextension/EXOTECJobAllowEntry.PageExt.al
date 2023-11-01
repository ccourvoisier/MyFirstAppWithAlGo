pageextension 50140 "EXOTEC JobAllowEntry" extends "Job Card"
{
    layout
    {
        addlast(General)
        {
            field("EXOTEC Allow Unknown Job Entry"; Rec."EXOTEC Allow Unknown Job Entry")
            {
                Importance = Additional;
                ApplicationArea = All;
                ToolTip = 'This option allow unknow inventory entry on the job';
            }
        }
    }
}