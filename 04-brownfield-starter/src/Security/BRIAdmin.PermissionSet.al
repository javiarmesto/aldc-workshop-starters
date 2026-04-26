permissionset 50922 "BRI-ADMIN"
{
    Assignable = true;
    Caption = 'BRI Incidents - Admin';

    Permissions =
        tabledata "BRI Incident" = RIMD,
        tabledata "BRI Incident Category" = RIMD,
        tabledata "BRI Incident Comment" = RIMD,
        tabledata "BRI Support Technician" = RIMD,
        tabledata "BRI Incident Cue" = RIMD,
        tabledata "Sales & Receivables Setup" = RM,
        page "BRI Incident List" = X,
        page "BRI Incident Card" = X,
        page "BRI Incident Comments Part" = X,
        page "BRI Incident Category List" = X,
        page "BRI Support Technician List" = X,
        page "BRI Incident Wizard" = X,
        page "BRI Incident Activities" = X,
        page "BRI Support Role Center" = X,
        codeunit "BRI Incident Management" = X,
        codeunit "BRI Demo Data Generator" = X;
}
