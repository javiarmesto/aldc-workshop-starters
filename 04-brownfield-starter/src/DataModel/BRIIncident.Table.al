table 50900 "BRI Incident"
{
    Caption = 'BRI Incident';
    DataClassification = CustomerContent;
    LookupPageId = "BRI Incident List";
    DrillDownPageId = "BRI Incident List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Detail Description"; Text[2048])
        {
            Caption = 'Detail Description';
            DataClassification = CustomerContent;
        }
        field(4; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
            TableRelation = "BRI Incident Category";

            trigger OnValidate()
            var
                BRICategory: Record "BRI Incident Category";
            begin
                if BRICategory.Get(Rec."Category Code") then
                    Rec.Priority := BRICategory."Default Priority";
            end;
        }
        field(5; Priority; Enum "BRI Incident Priority")
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(6; Status; Enum "BRI Incident Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get(Rec."Customer No.") then
                    Rec."Customer Name" := Customer.Name
                else
                    Rec."Customer Name" := '';
            end;
        }
        field(8; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(9; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            DataClassification = CustomerContent;
        }
        field(10; "Contact Email"; Text[100])
        {
            Caption = 'Contact Email';
            DataClassification = CustomerContent;
        }
        field(11; "Contact Phone"; Text[30])
        {
            Caption = 'Contact Phone';
            DataClassification = CustomerContent;
        }
        field(12; Channel; Enum "BRI Incident Channel")
        {
            Caption = 'Channel';
            DataClassification = CustomerContent;
        }
        field(13; "External Reference"; Text[50])
        {
            Caption = 'External Reference';
            DataClassification = CustomerContent;
        }
        field(14; "Assigned To"; Code[20])
        {
            Caption = 'Assigned To';
            DataClassification = CustomerContent;
            TableRelation = "BRI Support Technician" where(Active = const(true));
        }
        field(15; "Deadline Date"; Date)
        {
            Caption = 'Deadline Date';
            DataClassification = CustomerContent;
        }
        field(16; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(17; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Resolution Date"; Date)
        {
            Caption = 'Resolution Date';
            DataClassification = CustomerContent;
        }
        field(19; "Resolution Summary"; Text[2048])
        {
            Caption = 'Resolution Summary';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Key2; Status, "Assigned To") { }
        key(Key3; Priority, Status) { }
        key(Key4; "Customer No.") { }
        key(Key5; "Category Code") { }
    }

    trigger OnInsert()
    begin
        Rec."Creation Date" := Today();
        Rec."Created By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Created By"));
        Rec.Status := Rec.Status::New;
    end;
}
