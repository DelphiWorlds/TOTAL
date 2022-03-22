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
    'Android', 'Android64', ciOSDevice32Platform, ciOSDevice64Platform, ciOSSimulatorArm64Platform, cLinux64Platform, cOSX32Platform, cOSX64Platform,
    cOSXArm64Platform, cWin32Platform, cWin64Platform
  );

  cProjectPlatformsShort: array[TProjectPlatform] of string = (
    'Android', 'Android64', 'iOS32', 'iOS64', 'iOSSimArm64', 'Linux64', 'macOS32', 'macOS64', 'macOSArm64', 'Win32', 'Win64'
  );

  cProjectPlatformsLong: array[TProjectPlatform] of string = (
    'Android 32-bit', 'Android 64-bit', 'iOS 32-bit', 'iOS 64-bit', 'iOS Simulator Arm 64-bit', 'Linux 64-bit', 'macOS 32-bit', 'macOS 64-bit',
    'macOS Arm 64-bit', 'Windows 32-bit', 'Windows 64-bit'
  );

  cProjectPlatformDefaultBuildType: array[TProjectPlatform] of string = (
    'Development', 'Development', 'Development', 'Development', 'Development', '', 'Normal', 'Normal', 'Normal', 'Normal', 'Normal'
  );

  cProjectPlatformsRegistry: array[TProjectPlatform] of string = (
    'Android', 'Android64', 'iOSDevice32' , 'iOSDevice64', 'iOSSimulatorArm64', 'Linux64', 'OSX32', 'OSX64', 'OSXArm64', 'Win32', 'Win64'
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

  cMacOSPlatformNames: array[0..4] of string = (
    ciOSDevice32Platform, ciOSDevice64Platform, ciOSSimulator32Platform, cOSX32Platform, cOSX64Platform
  );
  cAppleProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.iOSSimulatorArm64, TProjectPlatform.iOSDevice64,
    TProjectPlatform.macOS32, TProjectPlatform.macOS64, TProjectPlatform.macOSArm64];
  cIOSProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.iOSSimulatorArm64, TProjectPlatform.iOSDevice64];
  cMacOSProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.macOS32, TProjectPlatform.macOS64, TProjectPlatform.macOSArm64];
  cAndroidProjectPlatforms: set of TProjectPlatform = [TProjectPlatform.Android32, TProjectPlatform.Android64];

  cTabChar = #9;
  cLineFeedChar = #10;
  cCarriageReturnChar = #13;

implementation

end.
