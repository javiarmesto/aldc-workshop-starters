pageextension 50917 "BRI SalesSetup PageExt" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(General)
        {
            group(BRIIncidentsGroup)
            {
                Caption = 'Barista Incidents';
                field("BRI Incident Nos."; Rec."BRI Incident Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number series used for Barista Incident numbers.';
                }
            }
        }
    }
}
