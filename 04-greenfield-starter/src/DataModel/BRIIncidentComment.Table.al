table 50902 "BRI Incident Comment"
{
    Caption = 'BRI Incident Comment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Incident No."; Code[20])
        {
            Caption = 'Incident No.';
            DataClassification = CustomerContent;
            TableRelation = "BRI Incident";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Comment Type"; Enum "BRI Comment Type")
        {
            Caption = 'Comment Type';
            DataClassification = CustomerContent;
        }
        field(4; Comment; Text[2048])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(5; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(6; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Incident No.", "Line No.") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        Rec."Created At" := CurrentDateTime();
        Rec."Created By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Created By"));
    end;
}
