codeunit 80060 "EXOTEC JobInvInbound Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        LicensePermission: Record "License Permission";
    begin
        if LicensePermission.GET(LicensePermission."Object Type"::Table, 130450) then
            IF (LicensePermission."Read Permission" = LicensePermission."Read Permission"::Yes) THEN
                Create('JobInvInb', '80060..80069');
    end;

    /// <summary> 
    /// Description for Create.
    /// </summary>
    /// <param name="TestSuiteName">Parameter of type code[10].</param>
    /// <param name="TestCodeunitFilter">Parameter of type Text.</param>
    local procedure Create(TestSuiteName: code[10]; TestCodeunitFilter: Text)
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        TestMethodLine: Record "Test Method Line";
    begin
        TryInsertTestSuite(TestSuiteName);
        TestMethodLine.SetRange("Test Suite", TestSuiteName);
        TestMethodLine.DELETEALL(TRUE);

        IF GetTestCodeunits(TestCodeunitFilter, TempAllObjWithCaption) THEN
            RefreshSuite(TestSuiteName, TempAllObjWithCaption);
    end;

    /// <summary> 
    /// Description for TryInsertTestSuite.
    /// </summary>
    /// <param name="TestSuiteName">Parameter of type code[10].</param>
    local procedure TryInsertTestSuite(TestSuiteName: code[10])
    var
        ALTestSuite: Record "AL Test Suite";
    begin
        if ALTestSuite.Get(TestSuiteName) then
            exit;
        ALTestSuite.init();
        ALTestSuite.VALIDATE(Name, TestSuiteName);
        ALTestSuite.VALIDATE(Description, TestSuiteName);
        ALTestSuite.INSERT(TRUE);
    end;

    /// <summary> 
    /// Description for GetTestCodeunits.
    /// </summary>
    /// <param name="TestCodeunitFilter">Parameter of type Text.</param>
    /// <param name="VAR ToAllObjWithCaption">Parameter of type Record AllObjWithCaption.</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure GetTestCodeunits(TestCodeunitFilter: Text; VAR ToAllObjWithCaption: Record AllObjWithCaption): Boolean;
    var
        FromAllObjWithCaption: Record AllObjWithCaption;
    begin
        FromAllObjWithCaption.SETRANGE("Object Type", ToAllObjWithCaption."Object Type"::Codeunit);
        FromAllObjWithCaption.SetFilter("Object ID", TestCodeunitFilter);
        FromAllObjWithCaption.SETRANGE("Object Subtype", 'Test');
        IF FromAllObjWithCaption.FIND('-') THEN
            REPEAT
                ToAllObjWithCaption := FromAllObjWithCaption;
                ToAllObjWithCaption.INSERT();
            UNTIL FromAllObjWithCaption.NEXT() = 0;
        EXIT(ToAllObjWithCaption.FIND('-'));
    end;

    /// <summary> 
    /// Description for RefreshSuite.
    /// </summary>
    /// <param name="ALTestSuiteName">Parameter of type Code[10].</param>
    /// <param name="VAR AllObjWithCaption">Parameter of type Record AllObjWithCaption.</param>
    local procedure RefreshSuite(ALTestSuiteName: Code[10]; VAR AllObjWithCaption: Record AllObjWithCaption);
    var
    begin
        AddTestCodeunits(ALTestSuiteName, AllObjWithCaption);
    end;

    /// <summary> 
    /// Description for AddTestCodeunits.
    /// </summary>
    /// <param name="ALTestSuiteName">Parameter of type Code[10].</param>
    /// <param name="VAR AllObjWithCaption">Parameter of type Record AllObjWithCaption.</param>
    local procedure AddTestCodeunits(ALTestSuiteName: Code[10]; VAR AllObjWithCaption: Record AllObjWithCaption);
    var
        TestLineNo: Integer;
    begin
        IF AllObjWithCaption.FIND('-') THEN BEGIN
            TestLineNo := GetLastTestLineNo(ALTestSuiteName);
            REPEAT
                TestLineNo := GetLastTestLineNo(ALTestSuiteName) + 10000;
                AddTestLine(ALTestSuiteName, AllObjWithCaption."Object ID", TestLineNo);
            UNTIL AllObjWithCaption.NEXT() = 0;
        END;
    end;

    /// <summary> 
    /// Description for GetLastTestLineNo.
    /// </summary>
    /// <param name="TestSuiteName">Parameter of type Code[10].</param>
    local procedure GetLastTestLineNo(TestSuiteName: Code[10]) LineNo: Integer;
    var
        TestMethodLine: Record "Test Method Line";
    begin
        TestMethodLine.SETRANGE("Test Suite", TestSuiteName);
        IF TestMethodLine.FINDLAST() THEN
            LineNo := TestMethodLine."Line No.";
    end;

    /// <summary> 
    /// Description for AddTestLine.
    /// </summary>
    /// <param name="TestSuiteName">Parameter of type Code[10].</param>
    /// <param name="TestCodeunitId">Parameter of type Integer.</param>
    /// <param name="LineNo">Parameter of type Integer.</param>
    local procedure AddTestLine(TestSuiteName: Code[10]; TestCodeunitId: Integer; LineNo: Integer);
    var
        AllObj: Record AllObj;
        TestMethodLine: Record "Test Method Line";
        CodeunitIsValid: Boolean;
    begin
        IF TestLineExists(TestSuiteName, TestCodeunitId) THEN
            EXIT;

        TestMethodLine.INIT();
        TestMethodLine.VALIDATE("Test Suite", TestSuiteName);
        TestMethodLine.VALIDATE("Line No.", LineNo);
        TestMethodLine.VALIDATE("Line Type", TestMethodLine."Line Type"::Codeunit);
        TestMethodLine.VALIDATE("Test Codeunit", TestCodeunitId);
        TestMethodLine.VALIDATE(Run, TRUE);

        TestMethodLine.INSERT(TRUE);

        AllObj.SETRANGE("Object Type", AllObj."Object Type"::Codeunit);
        AllObj.SETRANGE("Object ID", TestCodeunitId);
        IF FORMAT(AllObj."App Package ID") <> '' THEN
            CodeunitIsValid := TRUE;

        IF CodeunitIsValid THEN BEGIN

            TestMethodLine.SETRECFILTER();
            CODEUNIT.RUN(CODEUNIT::"Test Runner - Get Methods", TestMethodLine);
        END ELSE BEGIN
            TestMethodLine.VALIDATE(Result, TestMethodLine.Result::Failure);

            TestMethodLine.MODIFY(TRUE);
        END;
    end;

    /// <summary> 
    /// Description for TestLineExists.
    /// </summary>
    /// <param name="TestSuiteName">Parameter of type Code[10].</param>
    /// <param name="TestCodeunitId">Parameter of type Integer.</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure TestLineExists(TestSuiteName: Code[10]; TestCodeunitId: Integer): Boolean;
    var
        TestMethodLine: Record "Test Method Line";
    begin
        TestMethodLine.SETRANGE("Test Suite", TestSuiteName);
        TestMethodLine.SETRANGE("Test Codeunit", TestCodeunitId);
        EXIT(NOT TestMethodLine.ISEMPTY());
    end;

    //#region EventSubscriber Codeunit Object No. Trigger
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, true)]
    /// <summary> 
    /// Description for OnCreateCompany.
    /// </summary>
    local procedure OnCreateCompany()
    var
        LicensePermission: Record "License Permission";
    begin
        if LicensePermission.GET(LicensePermission."Object Type"::Table, 130450) then
            IF (LicensePermission."Read Permission" = LicensePermission."Read Permission"::Yes) THEN
                Create('JobInvInb', '80060..80069');
    end;
    //#endregion EventSubscriber Codeunit Object No. Trigger
}