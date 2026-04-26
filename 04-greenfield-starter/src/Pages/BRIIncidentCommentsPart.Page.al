page 50914 "BRI Incident Comments Part"
{
    PageType = ListPart;
    Caption = 'Comments';
    ApplicationArea = All;
    SourceTable = "BRI Incident Comment";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'When the comment was created.';
                }
                field("Comment Type"; Rec."Comment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type of comment.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who created the comment.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Comment text.';
                }
            }
        }
    }
}
