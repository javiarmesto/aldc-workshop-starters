# barista-incidents — Technical Specification

**Version:** 1.0
**Date:** 2026-04-20
**Complexity:** MEDIUM
**Status:** Draft

---

## 1. Overview

### Business Context
CRONUS USA, Inc. necesita centralizar la gestión de incidencias de clientes barista en Business Central. La extensión elimina la dependencia de hojas de cálculo y correos dispersos, introduce un ciclo de vida validado con 7 estados, maestro propio de técnicos y un Role Center operativo con cues en tiempo real.

### Scope
**Incluido**: Tablas propias (Incident, Category, Comment, Technician, Cue), extensión de Sales & Receivables Setup (serie numérica), enums (Status, Priority, Comment Type, Channel), codeunits de negocio y demo data, pages (List, Card, Comments Part, Category, Technician, Activities, RoleCenter, Wizard), page extension de Sales Setup, Profile, 3 Permission Sets.

**Excluido explícitamente**: API Pages OData, Assisted Setup registration, integración con tabla `User` de BC, notificaciones email, portal de cliente.

### Architecture Reference
Implementa `barista-incidents.architecture.md` — patrón **módulo autónomo con extensión mínima del core BC**. Todas las decisiones arquitectónicas D1–D5 son no negociables.

---

## 2. AL Object Inventory

| Object Type | Object ID | Name | Extends / Source | Purpose |
|-------------|-----------|------|-----------------|---------|
| Table | 50900 | `BRI Incident` | — | Entidad principal de incidencia |
| Table | 50901 | `BRI Incident Category` | — | Maestro de categorías |
| Table | 50902 | `BRI Incident Comment` | — | Historial append-only |
| Table | 50903 | `BRI Support Technician` | — | Maestro propio de técnicos (D1) |
| Table | 50904 | `BRI Incident Cue` | — | Cue table con 3 FlowFields |
| TableExtension | 50905 | `BRI SalesSetup Ext` | `Sales & Receivables Setup` (311) | Añade campo `BRI Incident Nos.` |
| Enum | 50906 | `BRI Incident Status` | — | 7 estados del ciclo de vida |
| Enum | 50907 | `BRI Incident Priority` | — | Low / Medium / High / Critical |
| Enum | 50908 | `BRI Comment Type` | — | 4 tipos de comentario |
| Enum | 50909 | `BRI Incident Channel` | — | 6 canales de entrada |
| Codeunit | 50910 | `BRI Incident Management` | — | Lógica de negocio central |
| Codeunit | 50911 | `BRI Demo Data Generator` | — | Generador idempotente de datos demo |
| Page | 50912 | `BRI Incident List` | `BRI Incident` | Lista con 3 vistas + StyleExpr |
| Page | 50913 | `BRI Incident Card` | `BRI Incident` | Ficha completa con FactBox |
| Page | 50914 | `BRI Incident Comments Part` | `BRI Incident Comment` | ListPart append-only |
| Page | 50915 | `BRI Incident Category List` | `BRI Incident Category` | Gestión de categorías |
| Page | 50916 | `BRI Support Technician List` | `BRI Support Technician` | Gestión de técnicos |
| PageExtension | 50917 | `BRI SalesSetup PageExt` | `Sales & Receivables Setup` (1363) | Expone campo Incident Nos. |
| Page | 50918 | `BRI Incident Wizard` | — | NavigatePage 3 pasos — UsageCategory=Tasks |
| Page | 50919 | `BRI Incident Activities` | `BRI Incident Cue` | CardPart 2 cuegroups (D2) |
| Page | 50920 | `BRI Support Role Center` | — | RoleCenter page (D2) |
| Profile | 50921 | `BRI SUPPORT AGENT` | — | Profile enlazado al Role Center |
| PermissionSet | 50922 | `BRI-ADMIN` | — | Acceso completo + X |
| PermissionSet | 50923 | `BRI-USER` | — | Agente de soporte + X |
| PermissionSet | 50924 | `BRI-READ` | — | Solo lectura + X |

> IDs 50900–50924 verificados contra `app.json` `idRanges` → `{ "from": 50900, "to": 50949 }` ✅

---

## 3. Data Model

### 3.1 Table 50900 `BRI Incident`

```al
table 50900 "BRI Incident"
{
    Caption = 'BRI Incident';
    DataClassification = CustomerContent;
    LookupPageId = "BRI Incident List";
    DrillDownPageId = "BRI Incident List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Detail Description"; Text[2048])
        {
            Caption = 'Detail Description';
            DataClassification = CustomerContent;
        }
        field(4; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
            TableRelation = "BRI Incident Category";

            trigger OnValidate()
            var
                BRICategory: Record "BRI Incident Category";
            begin
                if BRICategory.Get(Rec."Category Code") then
                    Rec.Priority := BRICategory."Default Priority";
            end;
        }
        field(5; Priority; Enum "BRI Incident Priority")
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(6; Status; Enum "BRI Incident Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get(Rec."Customer No.") then
                    Rec."Customer Name" := Customer.Name
                else
                    Rec."Customer Name" := '';
            end;
        }
        field(8; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(9; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            DataClassification = CustomerContent;
        }
        field(10; "Contact Email"; Text[100])
        {
            Caption = 'Contact Email';
            DataClassification = CustomerContent;
        }
        field(11; "Contact Phone"; Text[30])
        {
            Caption = 'Contact Phone';
            DataClassification = CustomerContent;
        }
        field(12; Channel; Enum "BRI Incident Channel")
        {
            Caption = 'Channel';
            DataClassification = CustomerContent;
        }
        field(13; "External Reference"; Text[50])
        {
            Caption = 'External Reference';
            DataClassification = CustomerContent;
        }
        field(14; "Assigned To"; Code[20])
        {
            Caption = 'Assigned To';
            DataClassification = CustomerContent;
            // D1: TableRelation a tabla PROPIA, NUNCA a tabla User de BC
            TableRelation = "BRI Support Technician" where(Active = const(true));
        }
        field(15; "Deadline Date"; Date)
        {
            Caption = 'Deadline Date';
            DataClassification = CustomerContent;
        }
        field(16; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(17; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Resolution Date"; Date)
        {
            Caption = 'Resolution Date';
            DataClassification = CustomerContent;
        }
        field(19; "Resolution Summary"; Text[2048])
        {
            Caption = 'Resolution Summary';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Key2; Status, "Assigned To") { }
        key(Key3; Priority, Status) { }
        key(Key4; "Customer No.") { }
        key(Key5; "Category Code") { }
    }

    trigger OnInsert()
    begin
        Rec."Creation Date" := Today();
        Rec."Created By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Created By"));
        Rec.Status := Rec.Status::New;
    end;
}
```

### 3.2 Table 50901 `BRI Incident Category`

```al
table 50901 "BRI Incident Category"
{
    Caption = 'BRI Incident Category';
    DataClassification = CustomerContent;
    LookupPageId = "BRI Incident Category List";
    DrillDownPageId = "BRI Incident Category List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Default Priority"; Enum "BRI Incident Priority")
        {
            Caption = 'Default Priority';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }
}
```

### 3.3 Table 50902 `BRI Incident Comment`

```al
table 50902 "BRI Incident Comment"
{
    Caption = 'BRI Incident Comment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Incident No."; Code[20])
        {
            Caption = 'Incident No.';
            DataClassification = CustomerContent;
            TableRelation = "BRI Incident";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Comment Type"; Enum "BRI Comment Type")
        {
            Caption = 'Comment Type';
            DataClassification = CustomerContent;
        }
        field(4; Comment; Text[2048])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(5; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(6; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Incident No.", "Line No.") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        Rec."Created At" := CurrentDateTime();
        Rec."Created By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Created By"));
    end;
}
```

### 3.4 Table 50903 `BRI Support Technician`

```al
table 50903 "BRI Support Technician"
{
    Caption = 'BRI Support Technician';
    DataClassification = CustomerContent;
    LookupPageId = "BRI Support Technician List";
    DrillDownPageId = "BRI Support Technician List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Email; Text[100])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
        field(4; "Specialty Category Code"; Code[20])
        {
            Caption = 'Specialty Category Code';
            DataClassification = CustomerContent;
            TableRelation = "BRI Incident Category";
        }
        field(5; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
        key(Key2; Active) { }
    }
}
```

### 3.5 Table 50904 `BRI Incident Cue`

```al
table 50904 "BRI Incident Cue"
{
    Caption = 'BRI Incident Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "My Open Incidents"; Integer)
        {
            Caption = 'My Open Incidents';
            DataClassification = CustomerContent;
            FieldClass = FlowField;
            // Limitación v1.0: funciona si Code del técnico = UserId() del usuario BC
            CalcFormula = count("BRI Incident" where("Assigned To" = filter('<UserId>'),
                                                      Status = filter(<> Closed & <> Cancelled)));
        }
        field(3; "Unassigned Incidents"; Integer)
        {
            Caption = 'Unassigned Incidents';
            DataClassification = CustomerContent;
            FieldClass = FlowField;
            CalcFormula = count("BRI Incident" where("Assigned To" = const(''),
                                                      Status = const(New)));
        }
        field(4; "Critical Open Incidents"; Integer)
        {
            Caption = 'Critical Open Incidents';
            DataClassification = CustomerContent;
            FieldClass = FlowField;
            CalcFormula = count("BRI Incident" where(Priority = const(Critical),
                                                      Status = filter(<> Closed & <> Cancelled)));
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
```

### 3.6 TableExtension 50905 `BRI SalesSetup Ext`

```al
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
```

### 3.7 Enums

```al
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

enum 50907 "BRI Incident Priority"
{
    Extensible = true;
    Caption = 'BRI Incident Priority';

    value(0; Low) { Caption = 'Low'; }
    value(1; Medium) { Caption = 'Medium'; }
    value(2; High) { Caption = 'High'; }
    value(3; Critical) { Caption = 'Critical'; }
}

enum 50908 "BRI Comment Type"
{
    Extensible = true;
    Caption = 'BRI Comment Type';

    value(0; User) { Caption = 'User'; }
    value(1; "Status Change") { Caption = 'Status Change'; }  // ⚠️ comillas obligatorias en referencias AL
    value(2; Assignment) { Caption = 'Assignment'; }
    value(3; Resolution) { Caption = 'Resolution'; }
}

enum 50909 "BRI Incident Channel"
{
    Extensible = true;
    Caption = 'BRI Incident Channel';

    value(0; Phone) { Caption = 'Phone'; }
    value(1; Email) { Caption = 'Email'; }
    value(2; Chat) { Caption = 'Chat'; }
    value(3; Portal) { Caption = 'Portal'; }
    value(4; Chatbot) { Caption = 'Chatbot'; }
    value(5; Other) { Caption = 'Other'; }
}
```

### Field Catalogue — `BRI Incident`

| Field No. | Field Name | Type | Length | Required | Relation | DataClassification |
|-----------|-----------|------|--------|----------|---------|-------------|
| 1 | `No.` | Code | 20 | Sí (auto) | — | CustomerContent |
| 2 | `Description` | Text | 100 | Sí | — | CustomerContent |
| 3 | `Detail Description` | Text | 2048 | No | — | CustomerContent |
| 4 | `Category Code` | Code | 20 | Sí | `BRI Incident Category` | CustomerContent |
| 5 | `Priority` | Enum | — | No (default desde Category) | — | CustomerContent |
| 6 | `Status` | Enum | — | Sí (default New) | — | CustomerContent |
| 7 | `Customer No.` | Code | 20 | No | `Customer` | CustomerContent |
| 8 | `Customer Name` | Text | 100 | No (auto) | — | CustomerContent |
| 9 | `Contact Name` | Text | 100 | No | — | CustomerContent |
| 10 | `Contact Email` | Text | 100 | No | — | CustomerContent |
| 11 | `Contact Phone` | Text | 30 | No | — | CustomerContent |
| 12 | `Channel` | Enum | — | No | — | CustomerContent |
| 13 | `External Reference` | Text | 50 | No | — | CustomerContent |
| 14 | `Assigned To` | Code | 20 | No | `BRI Support Technician` WHERE Active=true | CustomerContent |
| 15 | `Deadline Date` | Date | — | No | — | CustomerContent |
| 16 | `Creation Date` | Date | — | No (auto) | — | CustomerContent |
| 17 | `Created By` | Code | 50 | No (auto) | — | EndUserIdentifiableInformation |
| 18 | `Resolution Date` | Date | — | No (auto) | — | CustomerContent |
| 19 | `Resolution Summary` | Text | 2048 | No | — | CustomerContent |

---

## 4. Business Logic — Codeunit Procedures

### 4.1 Codeunit 50910 `BRI Incident Management`

```al
codeunit 50910 "BRI Incident Management"
{
    // Crea una nueva incidencia asignando el número de serie y valores iniciales.
    // Called by: BRI Incident Card (OnNewRecord/action), BRI Demo Data Generator
    procedure CreateIncident(var Incident: Record "BRI Incident")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        SalesSetup.TestField("BRI Incident Nos.");
        Incident."No." := NoSeries.GetNextNo(SalesSetup."BRI Incident Nos.", Today(), true);
        Incident."Creation Date" := Today();
        Incident."Created By" := CopyStr(UserId(), 1, MaxStrLen(Incident."Created By"));
        Incident.Status := Incident.Status::New;
        Incident.Insert(true);
    end;

    // Valida la transición de estado y genera comentario automático tipo "Status Change".
    // Called by: BRI Incident Card (Change Status, Resolve), ResolveIncident
    procedure UpdateStatus(var Incident: Record "BRI Incident"; NewStatus: Enum "BRI Incident Status")
    var
        InvalidTransitionErr: Label 'Cannot transition from %1 to %2.', Comment = '%1=current status, %2=new status';
    begin
        if not ValidateStatusTransition(Incident.Status, NewStatus) then
            Error(InvalidTransitionErr, Incident.Status, NewStatus);

        Incident.Status := NewStatus;
        Incident.Modify(true);

        InsertComment(Incident."No.",
                      Enum::"BRI Comment Type"::"Status Change",
                      StrSubstNo('%1 -> %2', Incident.Status, NewStatus));
    end;

    // Valida técnico activo, asigna y genera comentario de asignación.
    // Called by: BRI Incident Card (Assign Technician)
    procedure AssignIncident(var Incident: Record "BRI Incident"; TechnicianCode: Code[20])
    var
        Technician: Record "BRI Support Technician";
        TechnicianNotFoundErr: Label 'Technician %1 does not exist or is not active.', Comment = '%1=code';
        PreviousAssignee: Code[20];
    begin
        Technician.SetRange(Code, TechnicianCode);
        Technician.SetRange(Active, true);
        if not Technician.FindFirst() then
            Error(TechnicianNotFoundErr, TechnicianCode);

        PreviousAssignee := Incident."Assigned To";
        Incident."Assigned To" := TechnicianCode;
        Incident.Modify(true);

        InsertComment(Incident."No.",
                      Enum::"BRI Comment Type"::Assignment,
                      StrSubstNo('Assigned from %1 to %2', PreviousAssignee, TechnicianCode));
    end;

    // Inserta un comentario de tipo User en la incidencia.
    // Called by: BRI Incident Card (Add Comment)
    procedure AddComment(var Incident: Record "BRI Incident"; CommentText: Text[2048])
    begin
        InsertComment(Incident."No.", Enum::"BRI Comment Type"::User, CommentText);
    end;

    // Resuelve la incidencia: transición a Resolved, guarda resumen y fecha.
    // Called by: BRI Incident Card (Resolve)
    procedure ResolveIncident(var Incident: Record "BRI Incident"; ResolutionSummary: Text[2048])
    var
        ResolutionRequiredErr: Label 'Resolution Summary is required to resolve an incident.';
    begin
        if ResolutionSummary = '' then
            Error(ResolutionRequiredErr);

        UpdateStatus(Incident, Enum::"BRI Incident Status"::Resolved);
        Incident."Resolution Summary" := ResolutionSummary;
        Incident."Resolution Date" := Today();
        Incident.Modify(true);

        InsertComment(Incident."No.", Enum::"BRI Comment Type"::Resolution, ResolutionSummary);
    end;

    // Calcula el siguiente Line No. para los comentarios de una incidencia.
    local procedure GetNextLineNo(IncidentNo: Code[20]): Integer
    var
        BRIComment: Record "BRI Incident Comment";
    begin
        BRIComment.SetRange("Incident No.", IncidentNo);
        if BRIComment.FindLast() then
            exit(BRIComment."Line No." + 10000);
        exit(10000);
    end;

    // Inserta una línea de comentario en BRI Incident Comment.
    local procedure InsertComment(IncidentNo: Code[20]; CommentType: Enum "BRI Comment Type"; CommentText: Text[2048])
    var
        BRIComment: Record "BRI Incident Comment";
    begin
        BRIComment.Init();
        BRIComment."Incident No." := IncidentNo;
        BRIComment."Line No." := GetNextLineNo(IncidentNo);
        BRIComment."Comment Type" := CommentType;
        BRIComment.Comment := CommentText;
        BRIComment."Created At" := CurrentDateTime();
        BRIComment."Created By" := CopyStr(UserId(), 1, MaxStrLen(BRIComment."Created By"));
        BRIComment.Insert(true);
    end;

    // Valida si la transición de estado es permitida según la state machine.
    // INVÁLIDAS: New->Resolved/Closed; Closed->any; Cancelled->any
    local procedure ValidateStatusTransition(
        CurrentStatus: Enum "BRI Incident Status";
        NewStatus: Enum "BRI Incident Status"): Boolean
    begin
        // Estados finales: no se puede salir
        if CurrentStatus in [Enum::"BRI Incident Status"::Closed,
                              Enum::"BRI Incident Status"::Cancelled] then
            exit(false);

        // Saltos no permitidos desde New
        if CurrentStatus = Enum::"BRI Incident Status"::New then
            if NewStatus in [Enum::"BRI Incident Status"::Resolved,
                             Enum::"BRI Incident Status"::Closed] then
                exit(false);

        exit(true);
    end;
}
```

### 4.2 Codeunit 50911 `BRI Demo Data Generator`

```al
codeunit 50911 "BRI Demo Data Generator"
{
    // Genera datos demo de forma idempotente.
    // Idempotencia: verifica existencia de DEMO-* antes de cualquier insert; sale silenciosamente si ya existen.
    // Called by: BRI Incident Wizard (Step 3 — Finish con flag = true)
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

    // Crea las 5 categorías demo con prioridad por defecto.
    local procedure CreateDemoCategories()
    begin
        InsertCategory('DEMO-HW', 'Hardware Failure', Enum::"BRI Incident Priority"::High);
        InsertCategory('DEMO-SW', 'Software Issue', Enum::"BRI Incident Priority"::Medium);
        InsertCategory('DEMO-NET', 'Network Problem', Enum::"BRI Incident Priority"::High);
        InsertCategory('DEMO-ACC', 'Access Request', Enum::"BRI Incident Priority"::Medium);
        InsertCategory('DEMO-GEN', 'General Inquiry', Enum::"BRI Incident Priority"::Low);
    end;

    // Crea los 5 técnicos demo.
    local procedure CreateDemoTechnicians()
    begin
        InsertTechnician('DEMO-T001', 'Alice Martinez', 'alice@cronus.com', 'DEMO-HW');
        InsertTechnician('DEMO-T002', 'Bob Chen', 'bob@cronus.com', 'DEMO-SW');
        InsertTechnician('DEMO-T003', 'Carmen Ruiz', 'carmen@cronus.com', 'DEMO-NET');
        InsertTechnician('DEMO-T004', 'David Patel', 'david@cronus.com', 'DEMO-ACC');
        InsertTechnician('DEMO-T005', 'Elena Rossi', 'elena@cronus.com', 'DEMO-GEN');
    end;

    // Crea las 15 incidencias demo distribuidas por estado.
    // Distribución: 3 New / 4 In Progress / 1 Pending Customer / 1 Pending Internal /
    //               3 Resolved / 2 Closed / 1 Cancelled
    local procedure CreateDemoIncidents()
    var
        BRIIncidentMgt: Codeunit "BRI Incident Management";
        Customer: Record Customer;
        CustomerNos: array[3] of Code[20];
        CustomerCount: Integer;
    begin
        // Obtener hasta 3 clientes activos de CRONUS — D5: NO crear clientes nuevos
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        CustomerCount := 0;
        if Customer.FindSet() then
            repeat
                CustomerCount += 1;
                CustomerNos[CustomerCount] := Customer."No.";
            until (Customer.Next() = 0) or (CustomerCount = 3);

        // Usar cliente vacío si no hay clientes disponibles
        if CustomerCount = 0 then begin
            CustomerCount := 1;
            CustomerNos[1] := '';
        end;

        // Los métodos de inserción llaman BRIIncidentMgt para asegurar
        // la asignación de No. de serie y comentarios automáticos.
        // Ejemplo de llamada (repetir para las 15 incidencias con estados variados):
        //   CreateSingleIncident(BRIIncidentMgt, 'DEMO-INC-001', 'Barista machine not heating',
        //       'DEMO-HW', Enum::"BRI Incident Priority"::High,
        //       Enum::"BRI Incident Status"::New, CustomerNos[1], 'DEMO-T001');
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
```

---

## 5. Event Integration

### Publishers (eventos expuestos por esta extensión)

```al
// En: Codeunit 50910 "BRI Incident Management"
// Propósito: permite a partners / fase-2 suscribirse sin breaking change
[IntegrationEvent(false, false)]
procedure OnAfterCreateIncident(var Incident: Record "BRI Incident")
begin
end;
```

### Subscribers (v1.0 — ninguno)
La extensión no suscribe a eventos de BC en v1.0. La propagación de prioridad desde categoría se realiza en el `OnValidate` directo del campo `Category Code`.

---

## 6. Pages and UI

### 6.1 Page 50912 `BRI Incident List`

```al
page 50912 "BRI Incident List"
{
    PageType = List;
    Caption = 'BRI Incidents';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BRI Incident";
    CardPageId = "BRI Incident Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incident number.';
                    StyleExpr = IncidentStyleExpr;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incident description.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status.';
                    StyleExpr = IncidentStyleExpr;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the priority.';
                    StyleExpr = PriorityStyleExpr;
                }
                field("Category Code"; Rec."Category Code") { ApplicationArea = All; ToolTip = 'Specifies the category.'; }
                field("Assigned To"; Rec."Assigned To") { ApplicationArea = All; ToolTip = 'Specifies the assigned technician.'; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; ToolTip = 'Specifies the customer.'; }
                field("Creation Date"; Rec."Creation Date") { ApplicationArea = All; ToolTip = 'Specifies when the incident was created.'; }
            }
        }
    }

    views
    {
        view(MyOpen)
        {
            Caption = 'My Open';
            Filters = where("Assigned To" = filter('<UserId>'),
                            Status = filter(<> Closed & <> Cancelled));
        }
        view(AllOpen)
        {
            Caption = 'All Open';
            Filters = where(Status = filter(<> Closed & <> Cancelled));
        }
        view(Critical)
        {
            Caption = 'Critical';
            Filters = where(Priority = const(Critical),
                            Status = filter(<> Closed & <> Cancelled));
        }
    }

    var
        IncidentStyleExpr: Text;
        PriorityStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        SetStyleExpressions();
    end;

    local procedure SetStyleExpressions()
    begin
        case Rec.Status of
            Rec.Status::New:
                IncidentStyleExpr := 'Favorable';
            Rec.Status::"In Progress",
            Rec.Status::"Pending Customer",
            Rec.Status::"Pending Internal":
                IncidentStyleExpr := 'Attention';
            Rec.Status::Resolved:
                IncidentStyleExpr := 'Favorable';
            Rec.Status::Closed,
            Rec.Status::Cancelled:
                IncidentStyleExpr := 'Subordinate';
            else
                IncidentStyleExpr := '';
        end;

        case Rec.Priority of
            Rec.Priority::Critical:
                PriorityStyleExpr := 'Unfavorable';
            Rec.Priority::High:
                PriorityStyleExpr := 'Attention';
            else
                PriorityStyleExpr := '';
        end;
    end;
}
```

### 6.2 Page 50913 `BRI Incident Card`

```al
page 50913 "BRI Incident Card"
{
    PageType = Card;
    Caption = 'BRI Incident';
    ApplicationArea = All;
    SourceTable = "BRI Incident";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.") { ApplicationArea = All; ToolTip = 'Specifies the incident number.'; }
                field(Description; Rec.Description) { ApplicationArea = All; ToolTip = 'Specifies the description.'; }
                field(Status; Rec.Status) { ApplicationArea = All; ToolTip = 'Use actions to change status.'; Editable = false; }
                field(Priority; Rec.Priority) { ApplicationArea = All; ToolTip = 'Specifies the priority.'; }
                field("Category Code"; Rec."Category Code") { ApplicationArea = All; ToolTip = 'Specifies the category.'; }
            }
            group(Description)
            {
                Caption = 'Description';
                field("Detail Description"; Rec."Detail Description")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the full problem description.';
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; ToolTip = 'Specifies the customer.'; }
                field("Customer Name"; Rec."Customer Name") { ApplicationArea = All; Editable = false; ToolTip = 'Auto-filled from customer.'; }
                field("Contact Name"; Rec."Contact Name") { ApplicationArea = All; ToolTip = 'Specifies the reporter name.'; }
                field("Contact Email"; Rec."Contact Email") { ApplicationArea = All; ToolTip = 'Specifies the reporter email.'; }
                field("Contact Phone"; Rec."Contact Phone") { ApplicationArea = All; ToolTip = 'Specifies the reporter phone.'; }
            }
            group(Origin)
            {
                Caption = 'Origin';
                field(Channel; Rec.Channel) { ApplicationArea = All; ToolTip = 'Specifies the incoming channel.'; }
                field("External Reference"; Rec."External Reference") { ApplicationArea = All; ToolTip = 'Specifies an external ticket reference.'; }
                field("Creation Date"; Rec."Creation Date") { ApplicationArea = All; Editable = false; ToolTip = 'Auto-populated on insert.'; }
                field("Deadline Date"; Rec."Deadline Date") { ApplicationArea = All; ToolTip = 'Specifies the resolution deadline.'; }
            }
            group(Assignment)
            {
                Caption = 'Assignment';
                field("Assigned To"; Rec."Assigned To") { ApplicationArea = All; ToolTip = 'Specifies the assigned technician (active only).'; }
            }
            group(Resolution)
            {
                Caption = 'Resolution';
                Visible = ResolutionGroupVisible;
                field("Resolution Date"; Rec."Resolution Date") { ApplicationArea = All; Editable = false; ToolTip = 'Auto-populated on resolution.'; }
                field("Resolution Summary"; Rec."Resolution Summary")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the resolution summary.';
                }
            }
        }
        area(FactBoxes)
        {
            part(Comments; "BRI Incident Comments Part")
            {
                ApplicationArea = All;
                SubPageLink = "Incident No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ChangeStatus)
            {
                Caption = 'Change Status';
                ApplicationArea = All;
                Image = TransferToGeneralJournal;
                ToolTip = 'Change the status of this incident.';
                trigger OnAction()
                var
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                    NewStatus: Enum "BRI Incident Status";
                begin
                    // Solicitar nuevo estado al usuario (StrMenu o página dedicada)
                    // luego llamar:
                    BRIIncidentMgt.UpdateStatus(Rec, NewStatus);
                end;
            }
            action(AssignTechnician)
            {
                Caption = 'Assign Technician';
                ApplicationArea = All;
                Image = Resource;
                ToolTip = 'Assign an active technician to this incident.';
                trigger OnAction()
                var
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                    TechCode: Code[20];
                begin
                    // Solicitar código de técnico (lookup BRI Support Technician)
                    BRIIncidentMgt.AssignIncident(Rec, TechCode);
                end;
            }
            action(AddComment)
            {
                Caption = 'Add Comment';
                ApplicationArea = All;
                Image = Comment;
                ToolTip = 'Add a user comment to this incident.';
                trigger OnAction()
                var
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                    CommentText: Text[2048];
                begin
                    // Solicitar texto al usuario (InputDialog)
                    BRIIncidentMgt.AddComment(Rec, CommentText);
                    CurrPage.Comments.Page.Update();
                end;
            }
            action(Resolve)
            {
                Caption = 'Resolve';
                ApplicationArea = All;
                Image = Approve;
                ToolTip = 'Mark this incident as resolved with a resolution summary.';
                trigger OnAction()
                var
                    BRIIncidentMgt: Codeunit "BRI Incident Management";
                    ResolutionSummary: Text[2048];
                begin
                    // Solicitar resumen de resolución al usuario
                    BRIIncidentMgt.ResolveIncident(Rec, ResolutionSummary);
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        ResolutionGroupVisible: Boolean;

    trigger OnAfterGetRecord()
    begin
        ResolutionGroupVisible := Rec.Status in
            [Rec.Status::Resolved, Rec.Status::Closed];
    end;
}
```

### 6.3 Page 50914 `BRI Incident Comments Part`

```al
page 50914 "BRI Incident Comments Part"
{
    PageType = ListPart;
    Caption = 'Comments';
    ApplicationArea = All;
    SourceTable = "BRI Incident Comment";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Created At"; Rec."Created At") { ApplicationArea = All; ToolTip = 'When the comment was created.'; }
                field("Comment Type"; Rec."Comment Type") { ApplicationArea = All; ToolTip = 'Type of comment.'; }
                field("Created By"; Rec."Created By") { ApplicationArea = All; ToolTip = 'Who created the comment.'; }
                field(Comment; Rec.Comment) { ApplicationArea = All; ToolTip = 'Comment text.'; }
            }
        }
    }
    // Sin actions de New/Delete — append-only enforced en UI y en permisos (BRI-USER: RI solo)
}
```

### 6.4 Pages 50915 y 50916

```al
page 50915 "BRI Incident Category List"
{
    PageType = List;
    Caption = 'BRI Incident Categories';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BRI Incident Category";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code) { ApplicationArea = All; ToolTip = 'Category code.'; }
                field(Description; Rec.Description) { ApplicationArea = All; ToolTip = 'Category description.'; }
                field("Default Priority"; Rec."Default Priority") { ApplicationArea = All; ToolTip = 'Default priority for incidents in this category.'; }
            }
        }
    }
}

page 50916 "BRI Support Technician List"
{
    PageType = List;
    Caption = 'BRI Support Technicians';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BRI Support Technician";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code) { ApplicationArea = All; ToolTip = 'Technician code.'; }
                field(Name; Rec.Name) { ApplicationArea = All; ToolTip = 'Technician name.'; }
                field(Email; Rec.Email) { ApplicationArea = All; ToolTip = 'Technician email.'; }
                field("Specialty Category Code"; Rec."Specialty Category Code") { ApplicationArea = All; ToolTip = 'Specialty category.'; }
                field(Active; Rec.Active) { ApplicationArea = All; ToolTip = 'If false, technician is hidden in assignment lookups.'; }
            }
        }
    }
}
```

### 6.5 PageExtension 50917 `BRI SalesSetup PageExt`

```al
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
```

### 6.6 Page 50918 `BRI Incident Wizard` (NavigatePage — D4)

```al
page 50918 "BRI Incident Wizard"
{
    PageType = NavigatePage;
    Caption = 'Barista Incidents Setup';
    ApplicationArea = All;
    // D4: accesible desde Tell Me buscando "Barista Incidents Setup"
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(WelcomeStep)
            {
                Visible = WelcomeStepVisible;
                Caption = '';
                InstructionalText = 'Welcome to the Barista Incidents Setup Wizard. This wizard will help you configure the number series for incidents and optionally generate demo data. Click Next to continue.';
            }
            group(NoSeriesStep)
            {
                Visible = NoSeriesStepVisible;
                Caption = 'Number Series Configuration';
                InstructionalText = 'Select or create the number series for Barista Incident numbers.';
                field(IncidentNos; SalesSetup."BRI Incident Nos.")
                {
                    ApplicationArea = All;
                    Caption = 'BRI Incident Nos.';
                    ShowMandatory = true;
                    ToolTip = 'Number series for incident numbering.';
                }
                action(CreateDefaultSeries)
                {
                    ApplicationArea = All;
                    Caption = 'Create Default Series (INC)';
                    Image = New;
                    InFooterBar = false;
                    ToolTip = 'Creates series INC-00001..INC-99999 if none configured.';
                    trigger OnAction()
                    begin
                        CreateDefaultNoSeries();
                    end;
                }
            }
            group(DemoDataStep)
            {
                Visible = DemoDataStepVisible;
                Caption = 'Demo Data';
                InstructionalText = 'Optionally generate demo data: 5 categories, 5 technicians, 15 sample incidents. Idempotent — safe to run multiple times.';
                field(GenerateDemoDataFlag; GenerateDemoDataFlag)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Demo Data';
                    ToolTip = 'Select to generate sample data on Finish.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                Caption = '< Back';
                ApplicationArea = All;
                Image = PreviousRecord;
                InFooterBar = true;
                Visible = BackActionVisible;
                trigger OnAction()
                begin
                    NavigateBack();
                end;
            }
            action(ActionNext)
            {
                Caption = 'Next >';
                ApplicationArea = All;
                Image = NextRecord;
                InFooterBar = true;
                Visible = NextActionVisible;
                trigger OnAction()
                begin
                    NavigateNext();
                end;
            }
            action(ActionFinish)
            {
                Caption = 'Finish';
                ApplicationArea = All;
                Image = Approve;
                InFooterBar = true;
                Visible = FinishActionVisible;
                trigger OnAction()
                begin
                    FinishWizard();
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        SalesSetup: Record "Sales & Receivables Setup";
        Step: Option Welcome,"No. Series","Demo Data";
        WelcomeStepVisible: Boolean;
        NoSeriesStepVisible: Boolean;
        DemoDataStepVisible: Boolean;
        BackActionVisible: Boolean;
        NextActionVisible: Boolean;
        FinishActionVisible: Boolean;
        GenerateDemoDataFlag: Boolean;

    trigger OnOpenPage()
    begin
        SalesSetup.Get();
        Step := Step::Welcome;
        SetStepVisibility();
    end;

    local procedure NavigateNext()
    begin
        case Step of
            Step::Welcome:
                Step := Step::"No. Series";
            Step::"No. Series":
                begin
                    SalesSetup.TestField("BRI Incident Nos.");
                    Step := Step::"Demo Data";
                end;
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
        WelcomeStepVisible := Step = Step::Welcome;
        NoSeriesStepVisible := Step = Step::"No. Series";
        DemoDataStepVisible := Step = Step::"Demo Data";
        BackActionVisible := Step <> Step::Welcome;
        NextActionVisible := Step <> Step::"Demo Data";
        FinishActionVisible := Step = Step::"Demo Data";
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
        AlreadyExistsMsg: Label 'No. Series INC already exists.';
    begin
        if NoSeriesRec.Get('INC') then begin
            Message(AlreadyExistsMsg);
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
```

### 6.7 Page 50919 `BRI Incident Activities` (CardPart — D2)

```al
page 50919 "BRI Incident Activities"
{
    PageType = CardPart;
    Caption = 'Barista Incidents';
    ApplicationArea = All;
    SourceTable = "BRI Incident Cue";

    layout
    {
        area(Content)
        {
            cuegroup(Activities)
            {
                Caption = 'Activities';
                field("My Open Incidents"; Rec."My Open Incidents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Incidents assigned to you, not closed/cancelled.';
                    DrillDownPageId = "BRI Incident List";
                }
                field("Unassigned Incidents"; Rec."Unassigned Incidents")
                {
                    ApplicationArea = All;
                    ToolTip = 'New incidents not yet assigned to any technician.';
                    DrillDownPageId = "BRI Incident List";
                }
                field("Critical Open Incidents"; Rec."Critical Open Incidents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Open critical priority incidents.';
                    StyleExpr = CriticalStyleExpr;
                    DrillDownPageId = "BRI Incident List";
                }
            }
            cuegroup(QuickActions)
            {
                Caption = 'Quick Actions';
                actions
                {
                    action(NewIncident)
                    {
                        Caption = 'New Incident';
                        ApplicationArea = All;
                        Image = TileNew;
                        RunObject = page "BRI Incident Card";
                        RunPageMode = Create;
                        ToolTip = 'Create a new barista incident.';
                    }
                    action(AllIncidents)
                    {
                        Caption = 'All Incidents';
                        ApplicationArea = All;
                        Image = TileList;
                        RunObject = page "BRI Incident List";
                        ToolTip = 'Open the full incidents list.';
                    }
                    action(SetupWizard)
                    {
                        Caption = 'Setup Wizard';
                        ApplicationArea = All;
                        Image = TileSetup;
                        RunObject = page "BRI Incident Wizard";
                        ToolTip = 'Open the Barista Incidents setup wizard.';
                    }
                }
            }
        }
    }

    var
        CriticalStyleExpr: Text;

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
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Critical Open Incidents" > 0 then
            CriticalStyleExpr := 'Unfavorable'
        else
            CriticalStyleExpr := 'Favorable';
    end;
}
```

### 6.8 Page 50920 `BRI Support Role Center` + Profile 50921

```al
page 50920 "BRI Support Role Center"
{
    PageType = RoleCenter;
    Caption = 'Barista Support Role Center';
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
                Caption = 'Incidents';
                ApplicationArea = All;
                RunObject = page "BRI Incident List";
                Image = List;
                ToolTip = 'Open the incidents list.';
            }
            action(CategoryList)
            {
                Caption = 'Categories';
                ApplicationArea = All;
                RunObject = page "BRI Incident Category List";
                Image = Category;
                ToolTip = 'Open the categories list.';
            }
            action(TechnicianList)
            {
                Caption = 'Technicians';
                ApplicationArea = All;
                RunObject = page "BRI Support Technician List";
                Image = Resource;
                ToolTip = 'Open the technicians list.';
            }
        }
    }
}

profile "BRI SUPPORT AGENT"
{
    Caption = 'Barista Support Agent';
    ProfileDescription = 'Role center for CRONUS support agents managing barista incidents.';
    RoleCenter = "BRI Support Role Center";
    Enabled = true;
    Promoted = true;
}
```

---

## 7. Tests (Given/When/Then)

> **Sección omitida por decisión del usuario.**

---

## 8. Permission Sets

```al
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
        page "BRI SalesSetup PageExt" = X,
        page "BRI Incident Wizard" = X,
        page "BRI Incident Activities" = X,
        page "BRI Support Role Center" = X,
        codeunit "BRI Incident Management" = X,
        codeunit "BRI Demo Data Generator" = X;
}

permissionset 50923 "BRI-USER"
{
    Assignable = true;
    Caption = 'BRI Incidents - User';

    Permissions =
        tabledata "BRI Incident" = RIM,           // sin Delete
        tabledata "BRI Incident Category" = R,
        tabledata "BRI Incident Comment" = RI,    // sin Modify ni Delete — append-only
        tabledata "BRI Support Technician" = R,
        tabledata "BRI Incident Cue" = R,
        page "BRI Incident List" = X,
        page "BRI Incident Card" = X,
        page "BRI Incident Comments Part" = X,
        page "BRI Incident Wizard" = X,
        page "BRI Incident Activities" = X,
        page "BRI Support Role Center" = X,
        codeunit "BRI Incident Management" = X;
}

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
```

> ⚠️ **Regla crítica**: todos los permission sets incluyen entradas `X` sobre pages y codeunits. Sin estas entradas, usuarios sin SuperPermissions no pueden abrir las páginas.

---

## 9. API Endpoints

**N/A — Explícitamente fuera de alcance v1.0 (Decisión 3)**

El modelo de datos de `BRI Incident` está diseñado para ser additive: una API Page puede añadirse en fase 2 como objeto 50930+ sin modificar la tabla base.

---

## 10. AL-Go / CI Considerations

- [x] IDs 50900–50924 dentro del rango `app.json` 50900–50949 ✅
- [ ] `features = ["NoImplicitWith"]` activo — todos los snippets usan referencia explícita (`Rec.`, nombre de variable explícito)
- [ ] AppSourceCop AA0018: no usar `Codeunit.Run` para codeunits propias con parámetros
- [ ] Sin valores hardcoded de No. Series — siempre leer desde `Sales & Receivables Setup`
- [ ] Usar codeunit `No. Series` (System App BC 24+) en lugar del obsoleto `NoSeriesMgt`
- [ ] Test project separado con su propio `app.json` si se añaden tests en el futuro
- [ ] Translations: todas las `Caption` en inglés; añadir a XLF si se habilita soporte multi-idioma

---

## 11. Acceptance Criteria

### Functional
- [ ] AC-1: Un agente registra una incidencia completa en ≤ 5 clics desde el Role Center
- [ ] AC-2: `UpdateStatus` valida transiciones inválidas y lanza error claro con mensaje `Cannot transition from X to Y`
- [ ] AC-3: Role Center muestra 3 cues con contadores reales tras ejecutar demo data
- [ ] AC-4: `GenerateDemoData()` produce exactamente 5 categorías + 5 técnicos + 15 incidencias `DEMO-*`
- [ ] AC-5: Segunda ejecución de `GenerateDemoData()` no duplica registros
- [ ] AC-6: Campo `Assigned To` solo acepta técnicos con `Active = true`
- [ ] AC-7: Wizard accesible desde Tell Me buscando "Barista Incidents Setup"
- [ ] AC-8: Botón "Create Default Series" crea serie `INC` si no existe
- [ ] AC-9: Los 3 permission sets bloquean correctamente operaciones no permitidas

### Technical
- [ ] 25 objetos AL compilan sin errores en BC 28.0 sandbox
- [ ] `NoImplicitWith` — sin referencias implícitas en ningún objeto
- [ ] `DataClassification` definida en todos los campos
- [ ] Entradas `X` verificadas en los 3 permission sets
- [ ] FlowFields de `BRI Incident Cue` calculan correctamente en sandbox

### Quality
- [ ] Code review aprobado por `@AL Code Review Subagent`
- [ ] Enum valores con espacios (`"Status Change"`, `"In Progress"`, etc.) referenciados con comillas en todo el código

---

## 12. Open Questions

| # | Pregunta | Owner | Status |
|---|---------|-------|--------|
| OQ-01 | Publisher y App Name definitivos en `app.json`: ¿"Circe Innovation" / "WorkshopALDC_v3_Ejercicio" son los valores finales? | Human | Open |
| OQ-02 | BC target version: `app.json` apunta a BC 28.0, PRD a BC 27.0+. ¿Compilar contra BC 27 o BC 28? Afecta API de `No. Series` | Human | Open |
| OQ-03 | `Detail Description` y `Resolution Summary`: ¿`Text[2048]` suficiente o se requiere `BigText`? | Human | Open |
| OQ-04 | StyleExpr paleta de colores: spec propone `Favorable`/`Attention`/`Unfavorable`/`Subordinate`. ¿Confirmar con CRONUS? | Human | Open |
| OQ-05 | ¿Incluir en v1.0 un paso adicional en el wizard para dar de alta técnicos reales, o posponer a fase 2? | Human | Open |

---

## Next Steps

**Complexity: MEDIUM**

✅ Spec completa. Pasos siguientes:

1. **Revisión humana**: revisar y aprobar esta spec (especialmente snippets de código, state machine, permission sets)
2. **Arrancar implementación**:

```
@AL Development Conductor
Implementar barista-incidents siguiendo los contratos en .github/plans/barista-incidents/
Leer barista-incidents.spec.md y barista-incidents.architecture.md antes de empezar.
```

El Conductor orquestará las 4 fases:
- **Phase 1**: Tablas 50900–50904 + TableExt 50905 + Enums 50906–50909 + PermissionSets 50922–50924
- **Phase 2**: Codeunits 50910–50911
- **Phase 3**: Pages 50912–50916 + PageExtension 50917
- **Phase 4**: Pages 50918–50920 + Profile 50921
