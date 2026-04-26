enum 50906 "BRI Incident Status"
{
    Extensible = true;
    Caption = 'BRI Incident Status';

    value(0; New) { Caption = 'New'; }
    value(1; "In Progress") { Caption = 'In Progress'; }
    value(2; "Pending Customer") { Caption = 'Pending Customer'; }
    value(3; "Pending Internal") { Caption = 'Pending Internal'; }
    value(4; Resolved) { Caption = 'Resolved'; }
    value(5; Closed) { Caption = 'Closed'; }
    value(6; Cancelled) { Caption = 'Cancelled'; }
}
