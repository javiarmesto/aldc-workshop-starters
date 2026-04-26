table 50904 "BRI Incident Cue"
{
    Caption = 'BRI Incident Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "My Open Incidents"; Integer)
        {
            Caption = 'My Open Incidents';
            FieldClass = FlowField;
            CalcFormula = count("BRI Incident" where("Assigned To" = field("User ID Filter"),
                                                      Status = filter(<> Closed & <> Cancelled)));
        }
        field(3; "Unassigned Incidents"; Integer)
        {
            Caption = 'Unassigned Incidents';
            FieldClass = FlowField;
            CalcFormula = count("BRI Incident" where("Assigned To" = const(''),
                                                      Status = const(New)));
        }
        field(4; "Critical Open Incidents"; Integer)
        {
            Caption = 'Critical Open Incidents';
            FieldClass = FlowField;
            CalcFormula = count("BRI Incident" where(Priority = const(Critical),
                                                      Status = filter(<> Closed & <> Cancelled)));
        }
        field(10; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
