// ============================================================================
//  Sample AL object · HelloWorld.PageExt.al
//  Workshop V-Valley 2026 · Bloque 01 · Copilot playground
// ----------------------------------------------------------------------------
//  This file exists solely to prove the workspace compiles before students
//  start generating content with GitHub Copilot. It can be safely deleted or
//  replaced once you start the exercises.
// ============================================================================

pageextension 50100 "CEB Customer List Ext" extends "Customer List"
{
    trigger OnOpenPage()
    begin
        Message(HelloWorldTxt);
    end;

    var
        HelloWorldTxt: Label 'Workshop ALDC · ¡Hola desde la extensión del Bloque 01!';
}
