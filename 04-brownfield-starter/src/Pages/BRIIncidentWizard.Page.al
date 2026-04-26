page 50918 "BRI Incident Wizard"
{
  PageType = NavigatePage;
  Caption = 'Barista Incidents Setup Wizard';
  ApplicationArea = All;
  UsageCategory = Tasks;
  LinksAllowed = false;
  ShowFilter = false;

  layout
  {
    area(Content)
    {
      group(StepWelcomeGroup)
      {
        Visible = StepWelcomeVisible;
        Caption = '';
        InstructionalText = 'Welcome to Barista Incidents Setup. This wizard will help you configure the incident management module.';

        group(WelcomeInner)
        {
          Caption = 'Get Started';
          field(WelcomeText; WelcomeTextTxt)
          {
            ApplicationArea = All;
            ShowCaption = false;
            Editable = false;
            MultiLine = true;
            ToolTip = 'Displays the welcome message.';
          }
        }
      }

      group(StepNoSeriesGroup)
      {
        Visible = StepNoSeriesVisible;
        Caption = 'No. Series Configuration';
        InstructionalText = 'Configure the number series for incidents. Create a default series or select an existing one.';

        field(IncidentNos; SalesSetup."BRI Incident Nos.")
        {
          ApplicationArea = All;
          Caption = 'Incident No. Series';
          ToolTip = 'Specifies the number series used for incident numbers.';
        }
        field(CreateDefaultSeriesHint; CreateDefaultSeriesHintTxt)
        {
          ApplicationArea = All;
          ShowCaption = false;
          Editable = false;
          ToolTip = 'If no number series is configured, a default series (INC) will be created automatically on Next.';
        }
      }

      group(StepDemoDataGroup)
      {
        Visible = StepDemoDataVisible;
        Caption = 'Demo Data';
        InstructionalText = 'Optionally generate sample incidents, categories, and technicians for demonstration purposes.';

        field(GenerateDemoDataField; GenerateDemoDataFlag)
        {
          ApplicationArea = All;
          Caption = 'Generate Demo Data';
          ToolTip = 'Enable this option to generate sample data when finishing the wizard.';
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(Back)
      {
        ApplicationArea = All;
        Caption = '&Back';
        ToolTip = 'Go to the previous step.';
        Enabled = BackEnabled;
        Image = PreviousRecord;
        InFooterBar = true;

        trigger OnAction()
        begin
          NavigateBack();
        end;
      }

      action(Next)
      {
        ApplicationArea = All;
        Caption = '&Next';
        ToolTip = 'Go to the next step.';
        Enabled = NextEnabled;
        Image = NextRecord;
        InFooterBar = true;

        trigger OnAction()
        begin
          NavigateNext();
        end;
      }

      action(Finish)
      {
        ApplicationArea = All;
        Caption = '&Finish';
        ToolTip = 'Complete the setup wizard.';
        Enabled = FinishEnabled;
        Image = Approve;
        InFooterBar = true;

        trigger OnAction()
        begin
          FinishWizard();
          CurrPage.Close();
        end;
      }
    }
  }

  trigger OnOpenPage()
  begin
    SalesSetup.Get();
    Step := Step::Welcome;
    SetStepVisibility();
  end;

  trigger OnQueryClosePage(CloseAction: Action): Boolean
  var
    UnsavedChangesQst: Label 'Are you sure you want to close the wizard? Unsaved changes will be lost.';
  begin
    if CloseAction = Action::OK then
      exit(true);
    if Step = Step::"Demo Data" then
      exit(true);
    exit(Confirm(UnsavedChangesQst));
  end;

  var
    SalesSetup: Record "Sales & Receivables Setup";
    Step: Option Welcome,"No. Series","Demo Data";
    BackEnabled: Boolean;
    NextEnabled: Boolean;
    FinishEnabled: Boolean;
    StepWelcomeVisible: Boolean;
    StepNoSeriesVisible: Boolean;
    StepDemoDataVisible: Boolean;
    GenerateDemoDataFlag: Boolean;
    WelcomeTextTxt: Label 'Barista Incidents helps your support team manage customer incidents efficiently. Click Next to configure the module.';
    CreateDefaultSeriesHintTxt: Label 'If no number series is configured, a default series (INC) will be created automatically.';

  local procedure NavigateNext()
  begin
    case Step of
      Step::Welcome:
        Step := Step::"No. Series";
      Step::"No. Series":
        begin
          if SalesSetup."BRI Incident Nos." = '' then
            CreateDefaultNoSeries();
          Step := Step::"Demo Data";
        end;
      Step::"Demo Data":
        FinishWizard();
    end;
    SetStepVisibility();
  end;

  local procedure NavigateBack()
  begin
    case Step of
      Step::"No. Series":
        Step := Step::Welcome;
      Step::"Demo Data":
        Step := Step::"No. Series";
    end;
    SetStepVisibility();
  end;

  local procedure SetStepVisibility()
  begin
    StepWelcomeVisible := Step = Step::Welcome;
    StepNoSeriesVisible := Step = Step::"No. Series";
    StepDemoDataVisible := Step = Step::"Demo Data";
    BackEnabled := Step <> Step::Welcome;
    NextEnabled := Step <> Step::"Demo Data";
    FinishEnabled := Step = Step::"Demo Data";
  end;

  local procedure FinishWizard()
  var
    BRIDemoGen: Codeunit "BRI Demo Data Generator";
  begin
    SalesSetup.Modify();
    if GenerateDemoDataFlag then
      BRIDemoGen.GenerateDemoData();
  end;

  local procedure CreateDefaultNoSeries()
  var
    NoSeriesRec: Record "No. Series";
    NoSeriesLine: Record "No. Series Line";
  begin
    if NoSeriesRec.Get('INC') then begin
      SalesSetup."BRI Incident Nos." := 'INC';
      SalesSetup.Modify();
      exit;
    end;

    NoSeriesRec.Init();
    NoSeriesRec.Code := 'INC';
    NoSeriesRec.Description := 'Barista Incidents';
    NoSeriesRec."Default Nos." := true;
    NoSeriesRec."Manual Nos." := false;
    NoSeriesRec.Insert(true);

    NoSeriesLine.Init();
    NoSeriesLine."Series Code" := 'INC';
    NoSeriesLine."Line No." := 10000;
    NoSeriesLine."Starting Date" := WorkDate();
    NoSeriesLine."Starting No." := 'INC-00001';
    NoSeriesLine."Ending No." := 'INC-99999';
    NoSeriesLine."Increment-by No." := 1;
    NoSeriesLine.Insert(true);

    SalesSetup."BRI Incident Nos." := 'INC';
    SalesSetup.Modify();
  end;
}
