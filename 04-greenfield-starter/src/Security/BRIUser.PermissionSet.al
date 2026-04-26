permissionset 50923 "BRI-USER"
{
    Assignable = true;
    Caption = 'BRI Incidents - User';

    Permissions =
        tabledata "BRI Incident" = RIM,
        tabledata "BRI Incident Category" = R,
        tabledata "BRI Incident Comment" = RI,
        tabledata "BRI Support Technician" = R,
        tabledata "BRI Incident Cue" = R,
        tabledata "Sales & Receivables Setup" = R,
        page "BRI Incident List" = X,
        page "BRI Incident Card" = X,
        page "BRI Incident Comments Part" = X,
        page "BRI Incident Wizard" = X,
        page "BRI Incident Activities" = X,
        page "BRI Support Role Center" = X,
        codeunit "BRI Incident Management" = X;
}
