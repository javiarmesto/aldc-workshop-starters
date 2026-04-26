codeunit 50911 "BRI Demo Data Generator"
{
    procedure GenerateDemoData()
    var
        BRICategory: Record "BRI Incident Category";
        BRITechnician: Record "BRI Support Technician";
        BRIIncident: Record "BRI Incident";
    begin
        BRICategory.SetFilter(Code, 'DEMO-*');
        if not BRICategory.IsEmpty() then
            exit;
        BRITechnician.SetFilter(Code, 'DEMO-T*');
        if not BRITechnician.IsEmpty() then
            exit;
        BRIIncident.SetFilter("External Reference", 'DEMO-INC-*');
        if not BRIIncident.IsEmpty() then
            exit;

        CreateDemoCategories();
        CreateDemoTechnicians();
        CreateDemoIncidents();
    end;

    local procedure CreateDemoCategories()
    begin
        InsertCategory('DEMO-HW', 'Hardware Failure', Enum::"BRI Incident Priority"::High);
        InsertCategory('DEMO-SW', 'Software Issue', Enum::"BRI Incident Priority"::Medium);
        InsertCategory('DEMO-NET', 'Network Problem', Enum::"BRI Incident Priority"::High);
        InsertCategory('DEMO-ACC', 'Access Request', Enum::"BRI Incident Priority"::Medium);
        InsertCategory('DEMO-GEN', 'General Inquiry', Enum::"BRI Incident Priority"::Low);
    end;

    local procedure CreateDemoTechnicians()
    begin
        InsertTechnician('DEMO-T001', 'Alice Martinez', 'alice@cronus.com', 'DEMO-HW');
        InsertTechnician('DEMO-T002', 'Bob Chen', 'bob@cronus.com', 'DEMO-SW');
        InsertTechnician('DEMO-T003', 'Carmen Ruiz', 'carmen@cronus.com', 'DEMO-NET');
        InsertTechnician('DEMO-T004', 'David Patel', 'david@cronus.com', 'DEMO-ACC');
        InsertTechnician('DEMO-T005', 'Elena Rossi', 'elena@cronus.com', 'DEMO-GEN');
    end;

    local procedure CreateDemoIncidents()
    var
        Customer: Record Customer;
        BRIIncidentMgt: Codeunit "BRI Incident Management";
        CustomerNos: array[3] of Code[20];
        CustomerCount: Integer;
        Categories: array[5] of Code[20];
        Technicians: array[5] of Code[20];
    begin
        // Obtener hasta 3 clientes activos (D5: NO crear clientes)
        Customer.Reset();
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        CustomerCount := 0;
        if Customer.FindSet() then
            repeat
                CustomerCount += 1;
                CustomerNos[CustomerCount] := Customer."No.";
            until (Customer.Next() = 0) or (CustomerCount = 3);

        Categories[1] := 'DEMO-HW';
        Categories[2] := 'DEMO-SW';
        Categories[3] := 'DEMO-NET';
        Categories[4] := 'DEMO-ACC';
        Categories[5] := 'DEMO-GEN';

        Technicians[1] := 'DEMO-T001';
        Technicians[2] := 'DEMO-T002';
        Technicians[3] := 'DEMO-T003';
        Technicians[4] := 'DEMO-T004';
        Technicians[5] := 'DEMO-T005';

        // 3 New
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-001', 'Barista machine not heating',
            Categories[1], Enum::"BRI Incident Priority"::High,
            Enum::"BRI Incident Status"::New, GetCustomerNo(CustomerNos, CustomerCount, 1), Technicians[1], '', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-002', 'Software crashes on startup',
            Categories[2], Enum::"BRI Incident Priority"::Medium,
            Enum::"BRI Incident Status"::New, GetCustomerNo(CustomerNos, CustomerCount, 2), Technicians[2], '', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-003', 'Cannot connect to network share',
            Categories[3], Enum::"BRI Incident Priority"::High,
            Enum::"BRI Incident Status"::New, GetCustomerNo(CustomerNos, CustomerCount, 3), Technicians[3], '', '');

        // 4 In Progress
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-004', 'Grinder not working',
            Categories[1], Enum::"BRI Incident Priority"::Critical,
            Enum::"BRI Incident Status"::"In Progress", GetCustomerNo(CustomerNos, CustomerCount, 1), Technicians[4], '', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-005', 'POS system slow',
            Categories[2], Enum::"BRI Incident Priority"::Medium,
            Enum::"BRI Incident Status"::"In Progress", GetCustomerNo(CustomerNos, CustomerCount, 2), Technicians[5], '', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-006', 'WiFi intermittent',
            Categories[3], Enum::"BRI Incident Priority"::High,
            Enum::"BRI Incident Status"::"In Progress", GetCustomerNo(CustomerNos, CustomerCount, 3), Technicians[1], '', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-007', 'Access card not working',
            Categories[4], Enum::"BRI Incident Priority"::Medium,
            Enum::"BRI Incident Status"::"In Progress", GetCustomerNo(CustomerNos, CustomerCount, 1), Technicians[2], '', '');

        // 1 Pending Customer
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-008', 'Water filter replacement needed',
            Categories[1], Enum::"BRI Incident Priority"::Low,
            Enum::"BRI Incident Status"::"Pending Customer", GetCustomerNo(CustomerNos, CustomerCount, 2), Technicians[3], '', '');

        // 1 Pending Internal
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-009', 'Steam wand leaking',
            Categories[1], Enum::"BRI Incident Priority"::High,
            Enum::"BRI Incident Status"::"Pending Internal", GetCustomerNo(CustomerNos, CustomerCount, 3), Technicians[4], '', '');

        // 3 Resolved
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-010', 'Printer not printing receipts',
            Categories[2], Enum::"BRI Incident Priority"::Medium,
            Enum::"BRI Incident Status"::Resolved, GetCustomerNo(CustomerNos, CustomerCount, 1), Technicians[5],
            'Replaced paper roll and updated driver.', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-011', 'Login issues after update',
            Categories[4], Enum::"BRI Incident Priority"::High,
            Enum::"BRI Incident Status"::Resolved, GetCustomerNo(CustomerNos, CustomerCount, 2), Technicians[1],
            'Reset credentials and cleared cache.', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-012', 'General inquiry about warranty',
            Categories[5], Enum::"BRI Incident Priority"::Low,
            Enum::"BRI Incident Status"::Resolved, GetCustomerNo(CustomerNos, CustomerCount, 3), Technicians[2],
            'Provided warranty documentation.', '');

        // 2 Closed
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-013', 'Coffee machine maintenance',
            Categories[1], Enum::"BRI Incident Priority"::Low,
            Enum::"BRI Incident Status"::Closed, GetCustomerNo(CustomerNos, CustomerCount, 1), Technicians[3],
            'Scheduled and completed annual maintenance.', '');
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-014', 'Software license renewal',
            Categories[2], Enum::"BRI Incident Priority"::Medium,
            Enum::"BRI Incident Status"::Closed, GetCustomerNo(CustomerNos, CustomerCount, 2), Technicians[4],
            'License renewed for 1 year.', '');

        // 1 Cancelled
        CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-015', 'Duplicate network issue report',
            Categories[3], Enum::"BRI Incident Priority"::Low,
            Enum::"BRI Incident Status"::Cancelled, GetCustomerNo(CustomerNos, CustomerCount, 3), Technicians[5], '', '');
    end;

    local procedure CreateSingleIncident(
        var BRIIncidentMgt: Codeunit "BRI Incident Management";
        ExternalRef: Text[50];
        DescriptionText: Text[100];
        CategoryCode: Code[20];
        Priority: Enum "BRI Incident Priority";
        TargetStatus: Enum "BRI Incident Status";
        CustomerNo: Code[20];
        TechnicianCode: Code[20];
        ResolutionText: Text[2048];
        DetailDesc: Text[2048])
    var
        Incident: Record "BRI Incident";
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
        IncidentNo: Code[20];
    begin
        // Asignar número
        SalesSetup.Get();
        if SalesSetup."BRI Incident Nos." <> '' then
            IncidentNo := NoSeries.GetNextNo(SalesSetup."BRI Incident Nos.", Today(), true)
        else
            IncidentNo := CopyStr(ExternalRef, 1, 20);

        Incident.Init();
        Incident."No." := IncidentNo;
        Incident.Description := DescriptionText;
        Incident."Detail Description" := CopyStr(DetailDesc, 1, MaxStrLen(Incident."Detail Description"));
        Incident."Category Code" := CategoryCode;
        Incident.Priority := Priority;
        Incident.Status := Enum::"BRI Incident Status"::New;
        Incident."Customer No." := CustomerNo;
        Incident."External Reference" := CopyStr(ExternalRef, 1, MaxStrLen(Incident."External Reference"));
        Incident."Creation Date" := Today();
        Incident."Created By" := CopyStr(UserId(), 1, MaxStrLen(Incident."Created By"));
        Incident.Insert(true);

        // Asignar técnico
        if TechnicianCode <> '' then
            BRIIncidentMgt.AssignIncident(Incident, TechnicianCode);

        // Mover al estado destino
        case TargetStatus of
            Enum::"BRI Incident Status"::"In Progress":
                BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::"In Progress");
            Enum::"BRI Incident Status"::"Pending Customer":
                begin
                    BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::"In Progress");
                    BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::"Pending Customer");
                end;
            Enum::"BRI Incident Status"::"Pending Internal":
                begin
                    BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::"In Progress");
                    BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::"Pending Internal");
                end;
            Enum::"BRI Incident Status"::Resolved:
                begin
                    BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::"In Progress");
                    BRIIncidentMgt.ResolveIncident(Incident, ResolutionText);
                end;
            Enum::"BRI Incident Status"::Closed:
                begin
                    BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::"In Progress");
                    BRIIncidentMgt.ResolveIncident(Incident, ResolutionText);
                    BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::Closed);
                end;
            Enum::"BRI Incident Status"::Cancelled:
                BRIIncidentMgt.UpdateStatus(Incident, Enum::"BRI Incident Status"::Cancelled);
        end;
    end;

    local procedure GetCustomerNo(CustomerNos: array[3] of Code[20]; CustomerCount: Integer; Index: Integer): Code[20]
    begin
        if CustomerCount = 0 then
            exit('');
        exit(CustomerNos[((Index - 1) mod CustomerCount) + 1]);
    end;

    local procedure InsertCategory(CategoryCode: Code[20]; Description: Text[100]; DefaultPriority: Enum "BRI Incident Priority")
    var
        BRICategory: Record "BRI Incident Category";
    begin
        BRICategory.Init();
        BRICategory.Code := CategoryCode;
        BRICategory.Description := Description;
        BRICategory."Default Priority" := DefaultPriority;
        BRICategory.Insert(true);
    end;

    local procedure InsertTechnician(TechCode: Code[20]; TechName: Text[100]; TechEmail: Text[100]; SpecialtyCode: Code[20])
    var
        BRITechnician: Record "BRI Support Technician";
    begin
        BRITechnician.Init();
        BRITechnician.Code := TechCode;
        BRITechnician.Name := TechName;
        BRITechnician.Email := TechEmail;
        BRITechnician."Specialty Category Code" := SpecialtyCode;
        BRITechnician.Active := true;
        BRITechnician.Insert(true);
    end;
}
