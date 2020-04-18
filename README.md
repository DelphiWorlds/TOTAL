# TOTAL

TOTAL is an acronym for: Terrific Open Tools API Library

TOTAL is used as the foundation for the [Codex Delphi add-in](https://www.delphiworlds.com/Codex)

## Objective

The goal of TOTAL was to create a framework for creating Delphi add-ins, whilst keeping everything as simple as possible. Having said that, developing Delphi add-ins is by no means simple.

## Creating an add-in

**Note that TOTAL has a dependency on the [Kastri Free library](https://github.com/DelphiWorlds/KastriFree) **

1. In Delphi, File|New|Other, select Delphi, then Dynamic Library (currently only DLL add-ins are supported with TOTAL)
2. In the Project Options, select Building > Delphi Compiler, All configurations - All platforms
3. Optional: In Conditional Defines enter: EXPERT (please see below about how it is used)
4. In the Search Path box, ensure that you have paths to the API, Core and Include folders of Kastri Free
5. Create a 24x24 bitmap called Icon.bmp which will be used as the icon on the Delphi splash screen when your add-in loads, and save it in your add-in project folder
6. Create a new unit (this will be for the wizard for your add-in)
   Typically, your add-in will use a wizard based on TIDENotifierWizard. You can use the TotalDemo.OTAWizard unit from the demo project as a basis or as a guideline for your wizard
   The main requirements are the Initialize function, the exports and initialization sections at the bottom of the unit

This completes the basic requirements for your add-in.

## TOTAL helper functions

Total has a number of functions (in TOTAHelper record in the DW.OTA.Helpers unit) to help you code your add-in. Here are just a few:

### TOTAHelper.RegisterThemeForms

Call this method to register any forms you have in your add-in so that they are themed the same as the IDE

### TOTAHelper.ApplyTheme

Applies the active theme to a component and its children. Updates the UI properties like Color, Font.Color on controls that do not use style hooks (eg TLabel, TPanel etc)
If your form has these kinds of components, you could call this method when the form is created e.g. in an overridden Create method or OnCreate event, like this:

  `TOTAHelper.ApplyTheme(Self);`

### TOTAHelper.FindTopMenu

Finds a top-level menu in the IDE with the given *name*. Note that the name is usually different from the *caption*

### TOTAHelper.FindToolsMenu

Finds the Tools top-level menu item in the IDE. Use this if you want to place a menu item of your own under the Tools menu


There are a number of other helper functions - please refer to the DW.OTA.Helpers unit as they are all documented there

## Demo

There is a project in the Demo folder that you can use as a guide










