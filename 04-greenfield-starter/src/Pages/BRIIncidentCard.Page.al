page 50913 "BRI Incident Card"
{
    PageType = Card;
    Caption = 'BRI Incident';
    ApplicationArea = All;
    SourceTable = "BRI Incident";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incident number.';
                    Importance = Promoted;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                    Importance = Promoted;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Use actions to change status.';
                    Editable = false;
                    Importance = Promoted;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the priority.';
                }
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category.';
                }
            }
            group(DetailDescription)
            {
                Caption = 'Description';
                field("Detail Description"; Rec."Detail Description")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the full problem description.';
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Auto-filled from customer.';
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reporter name.';
                }
                field("Contact Email"; Rec."Contact Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reporter email.';
                }
                field("Contact Phone"; Rec."Contact Phone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reporter phone.';
                }
            }
            group(Origin)
            {
                Caption = 'Origin';
                field(Channel; Rec.Channel)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incoming channel.';
                }
                field("External Reference"; Rec."External Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an external ticket reference.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Auto-populated on insert.';
                }
                field("Deadline Date"; Rec."Deadline Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the resolution deadline.';
                }
            }
            group(Assignment)
            {
                Caption = 'Assignment';
                field("Assigned To"; Rec."Assigned To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the assigned technician (active only).';
                }
            }
            group(Resolution)
            {
                Caption = 'Resolution';
                Visible = ResolutionGroupVisible;
                field("Resolution Date"; Rec."Resolution Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Auto-populated on resolution.';
                }
                field("Resolution Summary"; Rec."Resolution Summary")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the resolution summary.';
                }
            }
        }
        area(FactBoxes)
        {
            part(Comments; "BRI Incident Comments Part")
            {
                ApplicationArea = All;
                SubPageLink = "Incident No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ChangeStatus)
            {
                ApplicationArea = All;
                Caption = 'Change Status';
                Image = ChangeStatus;
                ToolTip = 'Change the status of this incident.';

                trigger OnAction()
                var
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                    SelectedOption: Integer;
                    NewStatus: Enum "BRI Incident Status";
                begin
                    SelectedOption := StrMenu(
                        'In Progress,Pending Customer,Pending Internal,Resolved,Closed,Cancelled',
                        1,
                        'Select new status:');
                    if SelectedOption = 0 then
                        exit;
                    case SelectedOption of
                        1:
                            NewStatus := Enum::"BRI Incident Status"::"In Progress";
                        2:
                            NewStatus := Enum::"BRI Incident Status"::"Pending Customer";
                        3:
                            NewStatus := Enum::"BRI Incident Status"::"Pending Internal";
                        4:
                            NewStatus := Enum::"BRI Incident Status"::Resolved;
                        5:
                            NewStatus := Enum::"BRI Incident Status"::Closed;
                        6:
                            NewStatus := Enum::"BRI Incident Status"::Cancelled;
                    end;
                    BRIIncidentMgt.UpdateStatus(Rec, NewStatus);
                    CurrPage.Update();
                end;
            }
            action(AssignTechnician)
            {
                ApplicationArea = All;
                Caption = 'Assign Technician';
                Image = Resource;
                ToolTip = 'Assign a support technician to this incident.';

                trigger OnAction()
                var
                    Technician: Record "BRI Support Technician";
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                begin
                    Technician.SetRange(Active, true);
                    if Page.RunModal(Page::"BRI Support Technician List", Technician) = Action::LookupOK then begin
                        BRIIncidentMgt.AssignIncident(Rec, Technician.Code);
                        CurrPage.Update();
                    end;
                end;
            }
            action(AddComment)
            {
                ApplicationArea = All;
                Caption = 'Add Comment';
                Image = Comment;
                ToolTip = 'Add a comment to this incident via Codeunit BRI Incident Management.';

                trigger OnAction()
                var
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                    UseCommentsPanelMsg: Label 'To add a comment, use the Comments panel on the right side of this page.';
                begin
                    // Phase 4: No text input dialog available without a dedicated page.
                    // The Comments FactBox is read-only by design (append-only enforcement).
                    // Comments are inserted automatically by UpdateStatus, AssignIncident,
                    // and ResolveIncident via BRI Incident Management.
                    // Manual user comments require a dedicated input page (Phase 5 scope).
                    Message(UseCommentsPanelMsg);
                end;
            }
            action(Resolve)
            {
                ApplicationArea = All;
                Caption = 'Resolve';
                Image = Approve;
                ToolTip = 'Resolve this incident using the Resolution Summary field.';

                trigger OnAction()
                var
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                    ResolutionRequiredMsg: Label 'Please fill in the Resolution Summary field first.';
                begin
                    if Rec."Resolution Summary" = '' then begin
                        Message(ResolutionRequiredMsg);
                        exit;
                    end;
                    BRIIncidentMgt.ResolveIncident(Rec, Rec."Resolution Summary");
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(ChangeStatus_Promoted; ChangeStatus) { }
                actionref(AssignTechnician_Promoted; AssignTechnician) { }
                actionref(AddComment_Promoted; AddComment) { }
                actionref(Resolve_Promoted; Resolve) { }
            }
        }
    }

    var
        ResolutionGroupVisible: Boolean;

    trigger OnAfterGetRecord()
    begin
        // Show Resolution group when status allows filling the summary before resolving,
        // and after resolution/closure to display the filled values.
        ResolutionGroupVisible := Rec.Status in [
            Rec.Status::"In Progress",
            Rec.Status::"Pending Customer",
            Rec.Status::"Pending Internal",
            Rec.Status::Resolved,
            Rec.Status::Closed];
    end;
}
