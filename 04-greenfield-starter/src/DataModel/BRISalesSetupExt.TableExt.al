tableextension 50905 "BRI SalesSetup Ext" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50900; "BRI Incident Nos."; Code[20])
        {
            Caption = 'BRI Incident Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }
}
