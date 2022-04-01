unit DW.OTA.Consts;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  // Design
  PlatformConst, {$IF Defined(EXPERT)} ToolsAPI, {$ENDIF}
  // TOTAL
  DW.OTA.Types;

const
  cProjectPlatforms: array[TProjectPlatform] of string = (
    'Android', 'Android64', ciOSDevice32Platform, ciOSDevice64Platform,{$IF CompilerVersion > 34} ciOSSimulatorArm64Platform, {$ENDIF}cLinux64Platform, cOSX32Platform, cOSX64Platform,
    {$IF CompilerVersion > 34}cOSXArm64Platform,  {$ENDIF}cWin32Platform, cWin64Platform
  );

  cProjectPlatformsShort: array[TProjectPlatform] of string = (
    'Android', 'Android64', 'iOS32', 'iOS64', {$IF CompilerVersion > 34} 'iOSSimArm64',{$ENDIF} 'Linux64', 'macOS32', 'macOS64', {$IF CompilerVersion > 34}'macOSArm64', {$ENDIF}'Win32', 'Win64'
  );

  cProjectPlatformsLong: array[TProjectPlatform] of string = (
    'Android 32-bit', 'Android 64-bit', 'iOS 32-bit', 'iOS 64-bit',{$IF CompilerVersion > 34} 'iOS Simulator Arm 64-bit',{$ENDIF}  'Linux 64-bit', 'macOS 32-bit', 'macOS 64-bit',
    {$IF CompilerVersion > 34}'macOS Arm 64-bit',{$ENDIF} 'Windows 32-bit', 'Windows 64-bit'
  );

  cProjectPlatformDefaultBuildType: array[TProjectPlatform] of string = (
    'Development', 'Development', 'Development', 'Development', {$IF CompilerVersion > 34}'Development',{$ENDIF} '', 'Normal', 'Normal', {$IF CompilerVersion > 34}'Normal',{$ENDIF} 'Normal', 'Normal'
  );

  cProjectPlatformsRegistry: array[TProjectPlatform] of string = (
    'Android', 'Android64', 'iOSDevice32' , 'iOSDevice64', {$IF CompilerVersion > 34}'iOSSimulatorArm64',{$ENDIF} 'Linux64', 'OSX32', 'OSX64', {$IF CompilerVersion > 34}'OSXArm64',{$ENDIF} 'Win32', 'Win64'
  );

  cProjectConfigurations: array[TProjectConfiguration] of string = ('Debug', 'Release');

  {$IF Defined(EXPERT)}
  cCompileModes: array[TOTACompileMode] of string = ('Compile', 'Build', 'Check', 'Make Unit' {$IF CompilerVersion > 34}, 'Clean', 'Link'{$ENDIF});
  {$ENDIF}

  cBuildModes: array[TBuildMode] of string = ('Clean', 'Make', 'Build', 'Deploy');

  cDeployModes: array[TDeployMode] of string = ('', 'AdHoc', 'AppStore');

  cCompileResults: array[Boolean] of string = ('FAILED', 'Succeeded');

  cProjectOptionOutputDir = 'OutputDir';

  cProductVersionNumbers: array[17..24] of string = ('10', '10.1', '10.2', '10.3', '10.4', '11', '12', '13');

  {$IF Defined(EXPERT)}
  cIDEToolBarNames: array[0..14] of string = (
    sCustomToolBar, sStandardToolBar, sDebugToolBar, sViewToolBar, sDesktopToolBar, sAlignToolbar, sBrowserToolbar,
    sHTMLDesignToolbar, sHTMLFormatToolbar, sHTMLTableToolbar, sPersonalityToolBar, sPositionToolbar,
    sSpacingToolbar, sIDEInsightToolbar, sPlatformDeviceToolbar
  );
  {$ENDIF}

  {$IF CompilerVersion > 32}
  cMacOSPlatformNames: array[0..4] of string = (
    ciOSDevice32Platform, ciOSDevice64Platform, ciOSSimulator32Platform, cOSX32Platform, cOSX64Platform
  );
  {$ELSE}
  cMacOSPlatformNames: array[0..3] of string = (
    ciOSDevice32Platform, ciOSDevice64Platform, cOSX32Platform, cOSX64Platform
  );

  {$ENDIF}

  cAppleProjectPlatforms: set of TProjectPlatform = [{$IF CompilerVersion > 34}TProjectPlatform.iOSSimulatorArm64,{$ENDIF} TProjectPlatform.iOSDevice64,
    TProjectPlatform.macOS32, TProjectPlatform.macOS64{$IF CompilerVersion > 34}, TProjectPlatform.macOSArm64{$ENDIF}];
  cIOSProjectPlatforms: set of TProjectPlatform = [{$IF CompilerVersion > 34}TProjectPlatform.iOSSimulatorArm64,{$ENDIF} TProjectPlatform.iOSDevice64];
  cMacOSProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.macOS32, TProjectPlatform.macOS64{$IF CompilerVersion > 34}, TProjectPlatform.macOSArm64{$ENDIF}];
  cAndroidProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.Android32, TProjectPlatform.Android64];

  cTabChar = #9;
  cLineFeedChar = #10;
  cCarriageReturnChar = #13;

implementation

end.
