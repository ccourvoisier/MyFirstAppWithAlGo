codeunit 50141 "JobEntryCustomSubscribers"
{
    [EventSubscriber(ObjectType::Codeunit, 1011, 'OnBeforeCheckItemQuantityJobJnl', '', false, false)]
    /// <summary> 
    /// Description for C1011_OnBeforeCheckItemQuantityJobJnl.
    /// </summary>
    /// <param name="JobJnlLine">Parameter of type Record "Job Journal Line".</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
#pragma warning disable AA0072
    local procedure C1011_OnBeforeCheckItemQuantityJobJnl(var JobJnlLine: Record "Job Journal Line"; var IsHandled: Boolean)
#pragma warning restore
    var
        Job: Record Job;
        Location: Record Location;
        JobsSetup: Record "Jobs Setup";
    begin

        if JobJnlLine.Type = JobJnlLine.Type::Item then
            if (JobJnlLine."Quantity (Base)" < 0) and (JobJnlLine."Entry Type" = JobJnlLine."Entry Type"::Usage) then
                if not JobJnlline.IsNonInventoriableItem() then begin
                    job.get(JobJnlLine."Job No.");
                    if (Job.GetQuantityAvailable(JobJnlline."No.", JobJnlline."Location Code", JobJnlline."Variant Code", 0, 2) +
                    JobJnlline."Quantity (Base)") < 0 then begin
                        JobsSetup.Get();
                        JobsSetup.TestField("EXOTEC Job Inv. Inb. Rea Code");
                        Job.get(JobJnlLine."Job No.");
                        job.TestField("EXOTEC Allow Unknown Job Entry", true);
                        Location.get(JobJnlLine."Location Code");
                        Location.TestField("EXOTEC Allow Unknown Job Entry", true);
                        if JobJnlLine."Reason Code" = '' then
                            JobJnlLine.Validate("Reason Code", JobsSetup."EXOTEC Job Inv. Inb. Rea Code");
                        IsHandled := true;
                    end;
                end;
    end;

}