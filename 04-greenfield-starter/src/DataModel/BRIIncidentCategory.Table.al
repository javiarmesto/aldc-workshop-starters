table 50901 "BRI Incident Category"
{
    Caption = 'BRI Incident Category';
    DataClassification = CustomerContent;
    LookupPageId = "BRI Incident Category List";
    DrillDownPageId = "BRI Incident Category List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Default Priority"; Enum "BRI Incident Priority")
        {
            Caption = 'Default Priority';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }
}
