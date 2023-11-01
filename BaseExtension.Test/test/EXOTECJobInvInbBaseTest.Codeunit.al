codeunit 80061 "EXOTEC JobInvInbBaseTest"
{
    Subtype = Test;

    var
        NotAllowJobInboundJob: Record job;
        NotAllowJobInboundJobTask: Record "Job Task";
        AllowJobInboundJob: Record job;
        AllowJobInboundJobTask: Record "Job Task";
        AlreadyConsumeOnJobItem: Record Item;
        NeverConsumeOnJobItem: Record Item;
        NotAllowJobInboundLocation: Record Location;
        AllowJobInboundLocation: Record Location;
        ReasonCode: Record "Reason Code";
        Assert: Codeunit Assert;
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        //LibPat: Codeunit "Library - Patterns";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryERM: Codeunit "Library - ERM";
        Qty: Decimal;


    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    /// <summary> 
    /// Create a job, location and try to consume and reverse consumption on
    /// not autorize  job
    /// not autorize  location
    /// </summary>
    procedure TestStandardPostAndUnpostOnNotAutoriseLocAndJob()
    var
        AvailableQty: Decimal;
    begin
        //[GIVEN] given
        Initialize();
        //[WHEN] when
        PostJnlLineOnJob(NotAllowJobInboundJobTask, NotAllowJobInboundLocation.Code, AlreadyConsumeOnJobItem, qty, '');
        AvailableQty := NotAllowJobInboundJob.GetQuantityAvailable(AlreadyConsumeOnJobItem."No.", NotAllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, Qty, 'Wrong available quantity on Job after consumption');
        PostJnlLineOnJob(NotAllowJobInboundJobTask, NotAllowJobInboundLocation.Code, AlreadyConsumeOnJobItem, -qty, '');
        //[THEN] then
        AvailableQty := NotAllowJobInboundJob.GetQuantityAvailable(AlreadyConsumeOnJobItem."No.", NotAllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job after unconsumption');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    /// <summary> 
    /// Create a job, location and try to consume and reverse consumption on
    /// autorize  job
    /// autorize  location
    /// </summary>
    procedure TestStandardPostAndUnpostOnAutoriseLocAndJob()
    var
        AvailableQty: Decimal;
    begin
        //[GIVEN] given
        Initialize();
        //[WHEN] when
        PostJnlLineOnJob(AllowJobInboundJobTask, AllowJobInboundLocation.Code, AlreadyConsumeOnJobItem, qty, '');
        AvailableQty := AllowJobInboundJob.GetQuantityAvailable(AlreadyConsumeOnJobItem."No.", AllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, Qty, 'Wrong available quantity on Job after consumption');
        PostJnlLineOnJob(AllowJobInboundJobTask, AllowJobInboundLocation.Code, AlreadyConsumeOnJobItem, -qty, '');
        //[THEN] then
        AvailableQty := NotAllowJobInboundJob.GetQuantityAvailable(AlreadyConsumeOnJobItem."No.", NotAllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job after unconsumption');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    /// <summary> 
    /// Create a job, location and try to unconsume
    ///  not autorize  job
    ///  on blanck location
    /// </summary>
    procedure TestUnpostOnNotAutoJobAndNoLoc()
    var
        AvailableQty: Decimal;
    begin
        //[GIVEN] given
        Initialize();
        Qty := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        //[WHEN] when
        AvailableQty := NotAllowJobInboundJob.GetQuantityAvailable(AlreadyConsumeOnJobItem."No.", '', '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job before comsumption');
        //[THEN] then

        asserterror PostJnlLineOnJob(NotAllowJobInboundJobTask, '', NeverConsumeOnJobItem, -qty, '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    /// <summary> 
    ///  Create a job, location and try to unconsume on
    ///  not autorize location
    ///  autorize job  
    ///  without reason code
    /// </summary>
    procedure TestUnpostOnNotAutoJobAndAutoLoc()
    var
        AvailableQty: Decimal;
    begin
        //[GIVEN] given
        Initialize();

        //[WHEN] when
        AvailableQty := AllowJobInboundJob.GetQuantityAvailable(AlreadyConsumeOnJobItem."No.", NotAllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job before consumption');

        //[THEN] then
        asserterror PostJnlLineOnJob(AllowJobInboundJobTask, NotAllowJobInboundLocation.Code, NeverConsumeOnJobItem, -qty, '');


    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    /// <summary> 
    /// Create a job, location and try to unconsume on
    /// autorize location
    /// autorize job 
    /// without reason code
    /// </summary>
    procedure TestUnpostOnAutoJobAndAutoLoc()
    var
        AvailableQty: Decimal;
    begin
        //[GIVEN] given
        Initialize();

        //[WHEN] when

        AvailableQty := AllowJobInboundJob.GetQuantityAvailable(AlreadyConsumeOnJobItem."No.", AllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job before consumption');
        //[THEN] then
        asserterror PostJnlLineOnJob(AllowJobInboundJobTask, AllowJobInboundLocation.Code, NeverConsumeOnJobItem, -qty, '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    /// <summary> 
    /// Create a job, location and try to unconsume on
    ///  location autorise
    ///  job autorise 
    ///  with reason code on setup but no reason code on line
    /// </summary>
    procedure TestUnpostOnAutoJobAndAutoLocWithReasonCode()
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        JobsSetup: Record "Jobs Setup";
        AvailableQty: Decimal;
    begin
        //[GIVEN] given
        Initialize();
        JobsSetup.get();
        JobsSetup.Validate("EXOTEC Job Inv. Inb. Rea Code", ReasonCode.Code);
        JobsSetup.Modify(true);
        //[WHEN] when
        AvailableQty := AllowJobInboundJob.GetQuantityAvailable(NeverConsumeOnJobItem."No.", AllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job after consumption');
        //[THEN] then
        PostJnlLineOnJob(AllowJobInboundJobTask, AllowJobInboundLocation.Code, NeverConsumeOnJobItem, -qty, '');
        AvailableQty := AllowJobInboundJob.GetQuantityAvailable(NeverConsumeOnJobItem."No.", AllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(-qty, AvailableQty, 'Wrong available quantity on Job after unconsumption');
        JobLedgerEntry.FindLast();

        Assert.AreEqual(AllowJobInboundJobTask."Job No.", JobLedgerEntry."Job No.", 'Wrong Value of Job No. on Job Ledger Entry');
        Assert.AreEqual(AllowJobInboundJobTask."Job Task No.", JobLedgerEntry."Job Task No.", 'Wrong Value of Job Task No. on Job Ledger Entry');
        Assert.AreEqual(JobLedgerEntry.Type::Item, JobLedgerEntry.Type, 'Wrong Value of Type on Job Ledger Entry');
        Assert.AreEqual(NeverConsumeOnJobItem."No.", JobLedgerEntry."No.", 'Wrong Value of No." on Job Ledger Entry');
        Assert.AreEqual(-Qty, JobLedgerEntry."Quantity (Base)", 'Wrong Value of Quantity (Base)" on Job Ledger Entry');
        Assert.AreEqual(NeverConsumeOnJobItem."Unit Cost", JobLedgerEntry."Unit Cost", 'Wrong Value of Line Amount (LCY) on Job Ledger Entry');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler,JobCalcuteWipRequestPageHandler,JobPostWipToGlRequestPageHandler')]
    /// <summary> 
    /// Create a job, location and try to unconsume on
    ///  location autorise
    ///  job autorise 
    ///  with reason code on setup but no reason code on line
    /// </summary>
    procedure TestUnpostOnAutoJobAndAutoLocWithReasonCodeAndChkData()
    var

        JobsSetup: Record "Jobs Setup";
        AvailableQty: Decimal;
    begin
        //[GIVEN] given
        Initialize();
        JobsSetup.get();
        JobsSetup.Validate("EXOTEC Job Inv. Inb. Rea Code", ReasonCode.Code);
        JobsSetup.Modify(true);
        //[WHEN] when
        //Standard Usage
        PostJnlLineOnJob(NotAllowJobInboundJobTask, NotAllowJobInboundLocation.Code, NeverConsumeOnJobItem, qty, '');
        AvailableQty := NotAllowJobInboundJob.GetQuantityAvailable(NeverConsumeOnJobItem."No.", NotAllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, Qty, 'Wrong available quantity on Job after consumption');
        PostJnlLineOnJob(NotAllowJobInboundJobTask, NotAllowJobInboundLocation.Code, NeverConsumeOnJobItem, -qty, '');
        AvailableQty := NotAllowJobInboundJob.GetQuantityAvailable(NeverConsumeOnJobItem."No.", NotAllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job after unconsumption');

        //Specific Usage
        AvailableQty := AllowJobInboundJob.GetQuantityAvailable(NeverConsumeOnJobItem."No.", AllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(AvailableQty, 0, 'Wrong available quantity on Job after consumption');

        PostJnlLineOnJob(AllowJobInboundJobTask, AllowJobInboundLocation.Code, NeverConsumeOnJobItem, -qty, '');
        AvailableQty := AllowJobInboundJob.GetQuantityAvailable(NeverConsumeOnJobItem."No.", AllowJobInboundLocation.Code, '', 0, 2);
        Assert.AreEqual(-qty, AvailableQty, 'Wrong available quantity on Job after unconsumption');


        //THEN compare data
        CheckEntriesContent();

        RunWipCalculation(AllowJobInboundJob."No.");
        AllowJobInboundJob.CalcFields("Total WIP Cost Amount");
        Assert.AreEqual((NeverConsumeOnJobItem."Unit Cost" * -Qty), AllowJobInboundJob."Total WIP Cost Amount", 'Issue on Total Wip Cost Amount on Job which have been unconsume');

        PostWipToGl(AllowJobInboundJob."No.");
        AllowJobInboundJob.CalcFields("Total WIP Cost G/L Amount");
        Assert.AreEqual((NeverConsumeOnJobItem."Unit Cost" * -Qty), AllowJobInboundJob."Total WIP Cost G/L Amount", 'Issue on Total WIP Cost G/L Amount on Job which have been unconsume');
        ;
    end;
    /// <summary> 
    /// Description for PostWipToGl.
    /// </summary>
    /// <param name="JobNo">Parameter of type code[20].</param>
    procedure PostWipToGl(JobNo: code[20])
    var
        Job: Record job;
        JobCard: TestPage "Job Card";
    begin
        job.get(JobNo);
        JobCard.OpenEdit();
        JobCard.GoToRecord(job);
        JobCard."<Action83>".Invoke();
    end;

    [RequestPageHandler]
    /// <summary> 
    /// Description for JobCalcuteWipRequestPageHandler.
    /// </summary>
    /// <param name="RequestPageJobCalculateWIP">Parameter of type TestRequestPage "Job Calculate WIP".</param>
    procedure JobCalcuteWipRequestPageHandler(var RequestPageJobCalculateWIP: TestRequestPage "Job Calculate WIP")
    begin
        RequestPageJobCalculateWIP.OK().Invoke();
    end;

    [RequestPageHandler]
    /// <summary> 
    /// Description for JobPostWipToGlRequestPageHandler.
    /// </summary>
    /// <param name="RequestPageJobPostWIPtoGL">Parameter of type TestRequestPage "Job Post WIP to G/L".</param>
    procedure JobPostWipToGlRequestPageHandler(var RequestPageJobPostWIPtoGL: TestRequestPage "Job Post WIP to G/L")
    begin
        RequestPageJobPostWIPtoGL.OK().Invoke();
    end;
    /// <summary> 
    /// Description for RunWipCalculation.
    /// </summary>
    /// <param name="JobNo">Parameter of type code[20].</param>
    procedure RunWipCalculation(JobNo: code[20])
    var
        Job: Record Job;
        JobCard: TestPage "Job Card";
    begin
        job.get(JobNo);
        JobCard.OpenEdit();
        JobCard.GoToRecord(job);
        JobCard."<Action82>".Invoke();

    end;
    /// <summary> 
    /// Description for CheckEntriesContent.
    /// </summary>
    procedure CheckEntriesContent()
    var
        StdJobLedgerEntry: Record "Job Ledger Entry";
        SpeJobLedgerEntry: Record "Job Ledger Entry";
        StdItemLedgerEntry: Record "Item Ledger Entry";
        SpeItemLedgerEntry: Record "Item Ledger Entry";
        StdValueEntry: Record "Value Entry";
        SpeValueEntry: Record "Value Entry";
    begin
        StdJobLedgerEntry.SetRange("Job No.", NotAllowJobInboundJob."No.");
        StdJobLedgerEntry.FindLast();
        SpeJobLedgerEntry.SetRange("Job No.", AllowJobInboundJob."No.");
        SpeJobLedgerEntry.FindLast();
        CompareJobLedgerEntry(StdJobLedgerEntry, SpeJobLedgerEntry);
#pragma warning disable AA0210
        StdItemLedgerEntry.SetRange("Job No.", NotAllowJobInboundJob."No.");
#pragma warning restore
        StdItemLedgerEntry.FindLast();
#pragma warning disable AA0210
        SpeItemLedgerEntry.SetRange("Job No.", AllowJobInboundJob."No.");
#pragma warning restore
        SpeItemLedgerEntry.FindLast();
        CompareItemLedgerEntry(StdItemLedgerEntry, SpeItemLedgerEntry);
        StdValueEntry.SetRange("Item Ledger Entry No.", StdItemLedgerEntry."Entry No.");
        SpeValueEntry.SetRange("Item Ledger Entry No.", SpeItemLedgerEntry."Entry No.");
        CompareValueEntry(StdValueEntry, SpeValueEntry);
        Assert.AreEqual(true, AlreadyConsumeOnJobItem."Cost is Adjusted", 'Issue on cost is not adjusted on item already consume');
        Assert.AreEqual(true, NeverConsumeOnJobItem."Cost is Adjusted", 'Issue on cost is not adjusted on item never consume');
    end;

    /// <summary> 
    /// Description for CompareValueEntry.
    /// </summary>
    /// <param name="StdValueEntry">Parameter of type Record "Value Entry".</param>
    /// <param name="SpeValueEntry">Parameter of type record "Value Entry".</param>
    procedure CompareValueEntry(StdValueEntry: Record "Value Entry"; SpeValueEntry: record "Value Entry")
    var
        FirstRecordRef: RecordRef;
        SecondRecordRef: RecordRef;
    begin
        FirstRecordRef.GetTable(StdValueEntry);
        SecondRecordRef.GetTable(SpeValueEntry);
        DoCompareValueEntry(FirstRecordRef, SecondRecordRef);
    end;
    /// <summary> 
    /// Description for CompareReqWhseLine.
    /// </summary>
    /// <param name="FirstRecordRef">Parameter of type RecordRef.</param>
    /// <param name="SecondRecordRef">Parameter of type RecordRef.</param>
    procedure DoCompareValueEntry(FirstRecordRef: RecordRef; SecondRecordRef: RecordRef)
    var
        ValueEntry: Record "Value Entry";
        FirstFieldRef: FieldRef;
        SecondFieldRef: FieldRef;
        i: Integer;
    begin
        FOR i := 1 TO FirstRecordRef.FIELDCOUNT DO BEGIN
            FirstFieldRef := FirstRecordRef.FIELDINDEX(i);
            SecondFieldRef := SecondRecordRef.FIELDINDEX(i);
            if (i <> ValueEntry.FieldNo("Entry No.")) and (i <> ValueEntry.FieldNo("Source No.")) and (i <> ValueEntry.FieldNo("Document No.")) and (i <> ValueEntry.FieldNo("Location Code")) and (i <> ValueEntry.FieldNo("Job Task No.")) and (i <> ValueEntry.FieldNo("Applies-to Entry")) then
                IF FirstFieldRef.VALUE <> SecondFieldRef.VALUE THEN
                    error('difference between record field no. %1 %2 %3 | %4 record %5 | %6', format(i), FirstFieldRef.Caption, FirstFieldRef.VALUE, SecondFieldRef.VALUE, Format(FirstRecordRef), Format(SecondRecordRef));
        END;
    end;

    /// <summary> 
    /// Description for CompareItemLedgerEntry.
    /// </summary>
    /// <param name="StdItemLedgerEntry">Parameter of type Record "Item Ledger Entry".</param>
    /// <param name="SpeItemLedgerEntry">Parameter of type record "Item Ledger Entry".</param>
    procedure CompareItemLedgerEntry(StdItemLedgerEntry: Record "Item Ledger Entry"; SpeItemLedgerEntry: record "Item Ledger Entry")
    var
        FirstRecordRef: RecordRef;
        SecondRecordRef: RecordRef;
    begin
        FirstRecordRef.GetTable(StdItemLedgerEntry);
        SecondRecordRef.GetTable(SpeItemLedgerEntry);
        DoCompareItemLedgerEntry(FirstRecordRef, SecondRecordRef);
    end;
    /// <summary> 
    /// Description for CompareReqWhseLine.
    /// </summary>
    /// <param name="FirstRecordRef">Parameter of type RecordRef.</param>
    /// <param name="SecondRecordRef">Parameter of type RecordRef.</param>
    procedure DoCompareItemLedgerEntry(FirstRecordRef: RecordRef; SecondRecordRef: RecordRef)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        FirstFieldRef: FieldRef;
        SecondFieldRef: FieldRef;
        i: Integer;
    begin
        FOR i := 1 TO FirstRecordRef.FIELDCOUNT DO BEGIN
            FirstFieldRef := FirstRecordRef.FIELDINDEX(i);
            SecondFieldRef := SecondRecordRef.FIELDINDEX(i);
            if (i <> ItemLedgerEntry.FieldNo("Entry No.")) and (i <> ItemLedgerEntry.FieldNo("Source No.")) and (i <> ItemLedgerEntry.FieldNo("Document No.")) and (i <> ItemLedgerEntry.FieldNo("Location Code")) and (i <> 10) and (i <> 13) and (i <> 36) and (i <> ItemLedgerEntry.FieldNo("Job Task No.")) and (i <> ItemLedgerEntry.FieldNo("Applies-to Entry")) and (i <> 52) then
                IF FirstFieldRef.VALUE <> SecondFieldRef.VALUE THEN
                    error('difference between record field no. %1 %2 %3 | %4 record %5 | %6', format(i), FirstFieldRef.Caption, FirstFieldRef.VALUE, SecondFieldRef.VALUE, Format(FirstRecordRef), Format(SecondRecordRef));
        END;
    end;


    /// <summary> 
    /// Description for CompareJobLedgerEntry.
    /// </summary>
    /// <param name="StdJobLedgerEntry">Parameter of type Record "Job Ledger Entry".</param>
    /// <param name="SpeJobLedgerEntry">Parameter of type record "Job Ledger Entry".</param>
    procedure CompareJobLedgerEntry(StdJobLedgerEntry: Record "Job Ledger Entry"; SpeJobLedgerEntry: record "Job Ledger Entry")
    var
        FirstRecordRef: RecordRef;
        SecondRecordRef: RecordRef;
    begin
        FirstRecordRef.GetTable(StdJobLedgerEntry);
        SecondRecordRef.GetTable(SpeJobLedgerEntry);
        DoCompareJobLedgerEntry(FirstRecordRef, SecondRecordRef);

    end;
    /// <summary> 
    /// Description for CompareReqWhseLine.
    /// </summary>
    /// <param name="FirstRecordRef">Parameter of type RecordRef.</param>
    /// <param name="SecondRecordRef">Parameter of type RecordRef.</param>
    procedure DoCompareJobLedgerEntry(FirstRecordRef: RecordRef; SecondRecordRef: RecordRef)
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        FirstFieldRef: FieldRef;
        SecondFieldRef: FieldRef;
        i: Integer;
    begin
        FOR i := 1 TO FirstRecordRef.FIELDCOUNT DO BEGIN
            FirstFieldRef := FirstRecordRef.FIELDINDEX(i);
            SecondFieldRef := SecondRecordRef.FIELDINDEX(i);
            if (i <> JobLedgerEntry.FieldNo("Entry No.")) and (i <> JobLedgerEntry.FieldNo("Document No.")) and (i <> JobLedgerEntry.FieldNo("Job No.")) and (i <> JobLedgerEntry.FieldNo("Job Task No.")) and (i <> 16) and (i <> 28) and (i <> 29) and (i <> 58) then
                IF FirstFieldRef.VALUE <> SecondFieldRef.VALUE THEN
                    error('difference between record field no. %1 %2 %3 | %4 record %5 | %6', format(i), FirstFieldRef.Caption, FirstFieldRef.VALUE, SecondFieldRef.VALUE, Format(FirstRecordRef), Format(SecondRecordRef));
        END;
    end;

    [ConfirmHandler]
    /// <summary> 
    /// Description for ConfirmHandlerTrue.
    /// </summary>
    /// <param name="Question">Parameter of type text[1024].</param>
    /// <param name="Reply">Parameter of type Boolean.</param>
    procedure ConfirmHandlerTrue(Question: text[1024]; var Reply: Boolean);
    begin
        if (Question = 'Do you want to preview the posting accounts?') or (Question = 'WIP was calculated with warnings.\Do you want to preview the posting accounts?') then
            Reply := false
        else
            Reply := TRUE;
    end;

    [MessageHandler]
    /// <summary> 
    /// Handler to catch message from BC and check the content
    /// </summary>
    /// <param name="Message">Parameter of type Text[1024].</param>
    procedure MessageHandler(Message: Text[1024])
    begin

    end;

    /// <summary> 
    /// Description for Initialize.
    /// </summary>
    procedure Initialize()
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        JobWIPMethod: Record "Job WIP Method";
        LocationAllowJobInboundCode: Code[10];
        LocationNotAllowJobInboundCode: Code[10];

    begin

        LibraryJob.SetAutomaticUpdateJobItemCost(true);
        LibraryInventory.SetAutomaticCostAdjmtAlways();
        LibraryJob.CreateJobWIPMethod(JobWIPMethod);
        JobWIPMethod.Validate("Recognized Costs", JobWIPMethod."Recognized Costs"::"Usage (Total Cost)");
        JobWIPMethod.Validate("Recognized Sales", JobWIPMethod."Recognized Sales"::"Percentage of Completion");
        JobWIPMethod.validate(Valid, true);


        LibraryJob.CreateJob(AllowJobInboundJob);
        AllowJobInboundJob.validate("WIP Method", JobWIPMethod.Code);
        AllowJobInboundJob.Validate("EXOTEC Allow Unknown Job Entry", true);
        AllowJobInboundJob.Validate("Apply Usage Link", true);
        AllowJobInboundJob.validate("WIP Posting Method", AllowJobInboundJob."WIP Posting Method"::"Per Job");
        AllowJobInboundJob.Modify(true);

        LibraryJob.CreateJobTask(AllowJobInboundJob, AllowJobInboundJobTask);

        LibraryJob.CreateJob(NotAllowJobInboundJob);
        NotAllowJobInboundJob.validate("WIP Method", JobWIPMethod.Code);
        NotAllowJobInboundJob.validate("WIP Posting Method", NotAllowJobInboundJob."WIP Posting Method"::"Per Job");
        NotAllowJobInboundJob.Validate("Apply Usage Link", true);
        NotAllowJobInboundJob.Modify(true);
        LibraryJob.CreateJobTask(NotAllowJobInboundJob, NotAllowJobInboundJobTask);

        LibraryInventory.CreateItemManufacturing(AlreadyConsumeOnJobItem);
        AlreadyConsumeOnJobItem.Validate("Unit Cost", LibraryRandom.RandIntInRange(1, 1000));
        AlreadyConsumeOnJobItem.Modify(true);

        LibraryInventory.CreateItemManufacturing(NeverConsumeOnJobItem);
        NeverConsumeOnJobItem.Validate("Unit Cost", LibraryRandom.RandIntInRange(1, 1000));
        NeverConsumeOnJobItem.Modify(true);

        LocationAllowJobInboundCode := LibraryWarehouse.CreateLocationWithInventoryPostingSetup(AllowJobInboundLocation);
        AllowJobInboundLocation.get(LocationAllowJobInboundCode);
        AllowJobInboundLocation.Validate("EXOTEC Allow Unknown Job Entry", true);
        AllowJobInboundLocation.Modify(true);

        LocationNotAllowJobInboundCode := LibraryWarehouse.CreateLocationWithInventoryPostingSetup(NotAllowJobInboundLocation);
        NotAllowJobInboundLocation.get(LocationNotAllowJobInboundCode);

        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name, ItemJournalLine."Entry Type"::"Positive Adjmt.", AlreadyConsumeOnJobItem."No.", 100);
        ItemJournalLine.Validate("Location Code", AllowJobInboundLocation.Code);
        ItemJournalLine.Modify(true);
        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);

        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name, ItemJournalLine."Entry Type"::"Positive Adjmt.", AlreadyConsumeOnJobItem."No.", 100);
        ItemJournalLine.Validate("Location Code", NotAllowJobInboundLocation.Code);
        ItemJournalLine.Modify(true);
        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);

        LibraryERM.CreateReasonCode(ReasonCode);

        Qty := LibraryRandom.RandDecInDecimalRange(1, 100, 2);


    end;

    /// <summary> 
    /// Description for PostJnlLineOnJob.
    /// </summary>
    /// <param name="JobTask">Parameter of type record "Job Task".</param>
    /// <param name="LocationCode">Parameter of type Code[10].</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="Qty">Parameter of type Decimal.</param>
    /// <param name="ReasonCode">Parameter of type Code[10].</param>
    procedure PostJnlLineOnJob(JobTask: record "Job Task"; LocationCode: Code[10]; Item: Record Item; Qty: Decimal; ReasonCode: Code[10])
    var
        JobJournalLine: Record "Job Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.get();
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::" ", JobTask, JobJournalLine);
        JobJournalLine.Validate("Entry Type", JobJournalLine."Entry Type"::Usage);
        JobJournalLine.Validate("Posting Date", WorkDate());
        JobJournalLine.Validate("Source Code", SourceCodeSetup."Job Journal");
        JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
        JobJournalLine.Validate("No.", Item."No.");
        JobJournalLine.Validate(Quantity, Qty);
        JobJournalLine.Validate("Location Code", LocationCode);
        JobJournalLine.Validate("Reason Code", ReasonCode);
        JobJournalLine.TestField("Unit Cost");
        JobJournalLine.Modify();
        LibraryJob.PostJobJournal(JobJournalLine);

    end;


}