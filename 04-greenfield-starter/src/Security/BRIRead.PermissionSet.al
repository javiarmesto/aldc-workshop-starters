permissionset 50924 "BRI-READ"
{
    Assignable = true;
    Caption = 'BRI Incidents - Read Only';

    Permissions =
        tabledata "BRI Incident" = R,
        tabledata "BRI Incident Category" = R,
        tabledata "BRI Incident Comment" = R,
        tabledata "BRI Support Technician" = R,
        tabledata "BRI Incident Cue" = R,
        page "BRI Incident List" = X,
        page "BRI Incident Card" = X,
        page "BRI Incident Comments Part" = X,
        page "BRI Incident Activities" = X,
        page "BRI Support Role Center" = X;
}
