page 50919 "BRI Incident Activities"
{
  PageType = CardPart;
  Caption = 'BRI Incident Activities';
  SourceTable = "BRI Incident Cue";
  RefreshOnActivate = true;

  layout
  {
    area(Content)
    {
      cuegroup(ActivitiesGroup)
      {
        Caption = 'My Activities';

        field("My Open Incidents"; Rec."My Open Incidents")
        {
          ApplicationArea = All;
          ToolTip = 'Incidents assigned to you that are not closed or cancelled.';
          DrillDownPageId = "BRI Incident List";
        }
        field("Unassigned Incidents"; Rec."Unassigned Incidents")
        {
          ApplicationArea = All;
          ToolTip = 'Open incidents with no assigned technician.';
          DrillDownPageId = "BRI Incident List";
        }
        field("Critical Open Incidents"; Rec."Critical Open Incidents")
        {
          ApplicationArea = All;
          ToolTip = 'Critical priority incidents that are open.';
          DrillDownPageId = "BRI Incident List";
          StyleExpr = CriticalStyleExpr;
        }
      }

      cuegroup(QuickActionsGroup)
      {
        Caption = '';

        actions
        {
          action(NewIncident)
          {
            ApplicationArea = All;
            Caption = 'New Incident';
            ToolTip = 'Create a new incident.';
            RunObject = page "BRI Incident Card";
            RunPageMode = Create;
          }
          action(AllIncidents)
          {
            ApplicationArea = All;
            Caption = 'All Incidents';
            ToolTip = 'View all incidents.';
            RunObject = page "BRI Incident List";
          }
          action(SetupWizard)
          {
            ApplicationArea = All;
            Caption = 'Setup Wizard';
            ToolTip = 'Open the Barista Incidents setup wizard.';
            RunObject = page "BRI Incident Wizard";
          }
        }
      }
    }
  }

  trigger OnOpenPage()
  var
    BRIIncidentCue: Record "BRI Incident Cue";
  begin
    if not BRIIncidentCue.Get() then begin
      BRIIncidentCue.Init();
      BRIIncidentCue.Insert(true);
    end;
    Rec := BRIIncidentCue;
    Rec.CalcFields("My Open Incidents", "Unassigned Incidents", "Critical Open Incidents");
    if Rec."Critical Open Incidents" > 0 then
      CriticalStyleExpr := 'Unfavorable'
    else
      CriticalStyleExpr := 'Favorable';
  end;

  trigger OnAfterGetRecord()
  begin
    if Rec."Critical Open Incidents" > 0 then
      CriticalStyleExpr := 'Unfavorable'
    else
      CriticalStyleExpr := 'Favorable';
  end;

  var
    CriticalStyleExpr: Text;
}
