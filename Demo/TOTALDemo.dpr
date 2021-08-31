library TOTALDemo;

{$R 'Icon.res' '..\Icon.rc'}
{$R 'VersionInfo.res' 'VersionInfo.rc'}
{$I DW.LibSuffixIDE.inc}

uses
  System.SysUtils,
  System.Classes,
  TotalDemo.OTAWizard in 'TotalDemo.OTAWizard.pas',
  TotalDemo.Consts in 'TotalDemo.Consts.pas',
  TotalDemo.DockWindowForm in 'TotalDemo.DockWindowForm.pas' {DockWindowForm},
  TotalDemo.Resources in 'TotalDemo.Resources.pas' {Resources: TDataModule};

{$R *.res}

begin
end.
