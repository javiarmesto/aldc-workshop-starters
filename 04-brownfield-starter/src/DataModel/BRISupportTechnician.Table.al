table 50903 "BRI Support Technician"
{
    Caption = 'BRI Support Technician';
    DataClassification = CustomerContent;
    LookupPageId = "BRI Support Technician List";
    DrillDownPageId = "BRI Support Technician List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Email; Text[100])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
        field(4; "Specialty Category Code"; Code[20])
        {
            Caption = 'Specialty Category Code';
            DataClassification = CustomerContent;
            TableRelation = "BRI Incident Category";
        }
        field(5; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
        key(Key2; Active) { }
    }
}
