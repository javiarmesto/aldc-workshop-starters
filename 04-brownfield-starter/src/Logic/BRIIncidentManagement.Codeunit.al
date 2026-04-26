codeunit 50910 "BRI Incident Management"
{
    procedure CreateIncident(var Incident: Record "BRI Incident")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        SalesSetup.TestField("BRI Incident Nos.");
        Incident."No." := NoSeries.GetNextNo(SalesSetup."BRI Incident Nos.", Today(), true);
        Incident."Creation Date" := Today();
        Incident."Created By" := CopyStr(UserId(), 1, MaxStrLen(Incident."Created By"));
        Incident.Status := Incident.Status::New;
        Incident.Insert(true);
        OnAfterCreateIncident(Incident);
    end;

    procedure UpdateStatus(var Incident: Record "BRI Incident"; NewStatus: Enum "BRI Incident Status")
    var
        InvalidTransitionErr: Label 'Cannot transition from %1 to %2.', Comment = '%1=current status, %2=new status';
        OldStatus: Enum "BRI Incident Status";
    begin
        if not ValidateStatusTransition(Incident.Status, NewStatus) then
            Error(InvalidTransitionErr, Incident.Status, NewStatus);
        OldStatus := Incident.Status;
        Incident.Status := NewStatus;
        Incident.Modify(true);
        InsertComment(Incident."No.",
                      Enum::"BRI Comment Type"::"Status Change",
                      StrSubstNo('%1 -> %2', OldStatus, NewStatus));
    end;

    procedure AssignIncident(var Incident: Record "BRI Incident"; TechnicianCode: Code[20])
    var
        Technician: Record "BRI Support Technician";
        TechnicianNotFoundErr: Label 'Technician %1 does not exist or is not active.', Comment = '%1=code';
        AssignedFromToLbl: Label 'Assigned from %1 to %2', Comment = '%1=previous assignee, %2=new assignee';
        PreviousAssignee: Code[20];
    begin
        Technician.SetRange(Code, TechnicianCode);
        Technician.SetRange(Active, true);
        if Technician.IsEmpty() then
            Error(TechnicianNotFoundErr, TechnicianCode);
        PreviousAssignee := Incident."Assigned To";
        Incident."Assigned To" := TechnicianCode;
        Incident.Modify(true);
        InsertComment(Incident."No.",
                      Enum::"BRI Comment Type"::Assignment,
                      StrSubstNo(AssignedFromToLbl, PreviousAssignee, TechnicianCode));
    end;

    procedure AddComment(var Incident: Record "BRI Incident"; CommentText: Text[2048])
    begin
        InsertComment(Incident."No.", Enum::"BRI Comment Type"::User, CommentText);
    end;

    procedure ResolveIncident(var Incident: Record "BRI Incident"; ResolutionSummary: Text[2048])
    var
        ResolutionRequiredErr: Label 'Resolution Summary is required to resolve an incident.';
    begin
        if ResolutionSummary = '' then
            Error(ResolutionRequiredErr);
        UpdateStatus(Incident, Enum::"BRI Incident Status"::Resolved);
        Incident."Resolution Summary" := ResolutionSummary;
        Incident."Resolution Date" := Today();
        Incident.Modify(true);
        InsertComment(Incident."No.", Enum::"BRI Comment Type"::Resolution, ResolutionSummary);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCreateIncident(var Incident: Record "BRI Incident")
    begin
    end;

    local procedure GetNextLineNo(IncidentNo: Code[20]): Integer
    var
        BRIComment: Record "BRI Incident Comment";
    begin
        BRIComment.SetRange("Incident No.", IncidentNo);
        if BRIComment.FindLast() then
            exit(BRIComment."Line No." + 10000);
        exit(10000);
    end;

    local procedure InsertComment(IncidentNo: Code[20]; CommentType: Enum "BRI Comment Type"; CommentText: Text[2048])
    var
        BRIComment: Record "BRI Incident Comment";
    begin
        BRIComment.Init();
        BRIComment."Incident No." := IncidentNo;
        BRIComment."Line No." := GetNextLineNo(IncidentNo);
        BRIComment."Comment Type" := CommentType;
        BRIComment.Comment := CopyStr(CommentText, 1, MaxStrLen(BRIComment.Comment));
        BRIComment."Created At" := CurrentDateTime();
        BRIComment."Created By" := CopyStr(UserId(), 1, MaxStrLen(BRIComment."Created By"));
        BRIComment.Insert(true);
    end;

    local procedure ValidateStatusTransition(
        CurrentStatus: Enum "BRI Incident Status";
        NewStatus: Enum "BRI Incident Status"): Boolean
    begin
        // Estados finales: Closed y Cancelled — no se puede salir
        if CurrentStatus in [Enum::"BRI Incident Status"::Closed,
                              Enum::"BRI Incident Status"::Cancelled] then
            exit(false);

        // Desde New: no se puede saltar a Resolved ni Closed
        if CurrentStatus = Enum::"BRI Incident Status"::New then
            if NewStatus in [Enum::"BRI Incident Status"::Resolved,
                             Enum::"BRI Incident Status"::Closed] then
                exit(false);

        exit(true);
    end;
}
