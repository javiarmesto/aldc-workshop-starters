page 50915 "BRI Incident Category List"
{
    PageType = List;
    Caption = 'BRI Incident Categories';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BRI Incident Category";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Category code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Category description.';
                }
                field("Default Priority"; Rec."Default Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'Default priority for incidents in this category.';
                }
            }
        }
    }
}
