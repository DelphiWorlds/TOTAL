unit DW.OTA.Consts;

{*******************************************************}
{                                                       }
{         DelphiWorlds Open Tools API Support           }
{                                                       }
{          Copyright(c) 2019 David Nottage              }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

uses
  // Design
  PlatformConst, {$IF Defined(EXPERT)} ToolsAPI, {$ENDIF}
  // DW
  DW.OTA.Types;

const
  cProjectPlatforms: array[TProjectPlatform] of string = (
    'Android32', 'Android64', ciOSDevice32Platform , ciOSDevice64Platform, ciOSSimulator32Platform, cLinux64Platform, cOSX32Platform, cOSX64Platform,
    cWin32Platform, cWin64Platform
  );

  cProjectConfigurations: array[TProjectConfiguration] of string = ('Debug', 'Release');

  {$IF Defined(EXPERT)}
  cCompileModes: array[TOTACompileMode] of string = ('Compile', 'Build', 'Check', 'Make Unit');
  {$ENDIF}

  cBuildModes: array[TBuildMode] of string = ('Clean', 'Make', 'Build', 'Deploy');

  cDeployModes: array[TDeployMode] of string = ('', 'AdHoc', 'AppStore');

  cCompileResults: array[Boolean] of string = ('FAILED', 'Succeeded');

  cProjectOptionOutputDir = 'OutputDir';

  cProductVersionNumbers: array[17..23] of string = ('10', '10.1', '10.2', '10.3', '10.4', '10.5', '10.6');

  {$IF Defined(EXPERT)}
  cIDEToolBarNames: array[0..14] of string = (
    sCustomToolBar, sStandardToolBar, sDebugToolBar, sViewToolBar, sDesktopToolBar, sAlignToolbar, sBrowserToolbar,
    sHTMLDesignToolbar, sHTMLFormatToolbar, sHTMLTableToolbar, sPersonalityToolBar, sPositionToolbar,
    sSpacingToolbar, sIDEInsightToolbar, sPlatformDeviceToolbar
  );
  {$ENDIF}

  cMacOSPlatformNames: array[0..4] of string = (
    ciOSDevice32Platform, ciOSDevice64Platform, ciOSSimulator32Platform, cOSX32Platform, cOSX64Platform
  );
  cAppleProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.iOSDevice32, TProjectPlatform.iOSDevice64,
    TProjectPlatform.macOS32, TProjectPlatform.macOS64];
  cMacOSProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.macOS32, TProjectPlatform.macOS64];

implementation

end.
