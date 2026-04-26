page 50912 "BRI Incident List"
{
    PageType = List;
    Caption = 'BRI Incidents';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BRI Incident";
    CardPageId = "BRI Incident Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incident number.';
                    StyleExpr = IncidentStyleExpr;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incident description.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status.';
                    StyleExpr = IncidentStyleExpr;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the priority.';
                    StyleExpr = PriorityStyleExpr;
                }
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category.';
                }
                field("Assigned To"; Rec."Assigned To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the assigned technician.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the incident was created.';
                }
            }
        }
    }

    views
    {
        view(MyOpen)
        {
            Caption = 'My Open';
            Filters = where("Assigned To" = filter('<UserId>'),
                            Status = filter(<> Closed & <> Cancelled));
        }
        view(AllOpen)
        {
            Caption = 'All Open';
            Filters = where(Status = filter(<> Closed & <> Cancelled));
        }
        view(Critical)
        {
            Caption = 'Critical';
            Filters = where(Priority = const(Critical),
                            Status = filter(<> Closed & <> Cancelled));
        }
    }

    var
        IncidentStyleExpr: Text;
        PriorityStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        SetStyleExpressions();
    end;

    local procedure SetStyleExpressions()
    begin
        case Rec.Status of
            Rec.Status::New:
                IncidentStyleExpr := 'Favorable';
            Rec.Status::"In Progress",
            Rec.Status::"Pending Customer",
            Rec.Status::"Pending Internal":
                IncidentStyleExpr := 'Attention';
            Rec.Status::Resolved:
                IncidentStyleExpr := 'Favorable';
            Rec.Status::Closed,
            Rec.Status::Cancelled:
                IncidentStyleExpr := 'Subordinate';
            else
                IncidentStyleExpr := '';
        end;

        case Rec.Priority of
            Rec.Priority::Critical:
                PriorityStyleExpr := 'Unfavorable';
            Rec.Priority::High:
                PriorityStyleExpr := 'Attention';
            else
                PriorityStyleExpr := '';
        end;
    end;
}
