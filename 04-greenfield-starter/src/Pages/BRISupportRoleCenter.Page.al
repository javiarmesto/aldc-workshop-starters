page 50920 "BRI Support Role Center"
{
  PageType = RoleCenter;
  Caption = 'BRI Support Agent';
  ApplicationArea = All;

  layout
  {
    area(RoleCenter)
    {
      part(Activities; "BRI Incident Activities")
      {
        ApplicationArea = All;
      }
    }
  }

  actions
  {
    area(Embedding)
    {
      action(IncidentList)
      {
        ApplicationArea = All;
        Caption = 'Incidents';
        ToolTip = 'View all incidents.';
        RunObject = page "BRI Incident List";
        Image = List;
      }
      action(CategoryList)
      {
        ApplicationArea = All;
        Caption = 'Categories';
        ToolTip = 'View incident categories.';
        RunObject = page "BRI Incident Category List";
        Image = Category;
      }
      action(TechnicianList)
      {
        ApplicationArea = All;
        Caption = 'Technicians';
        ToolTip = 'View support technicians.';
        RunObject = page "BRI Support Technician List";
        Image = TeamSales;
      }
    }
  }
}
