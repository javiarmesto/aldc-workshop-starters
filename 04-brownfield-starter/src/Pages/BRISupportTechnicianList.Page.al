page 50916 "BRI Support Technician List"
{
    PageType = List;
    Caption = 'BRI Support Technicians';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BRI Support Technician";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Technician code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Technician name.';
                }
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                    ToolTip = 'Technician email.';
                }
                field("Specialty Category Code"; Rec."Specialty Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specialty category.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'If false, technician is hidden in assignment lookups.';
                }
            }
        }
    }
}
