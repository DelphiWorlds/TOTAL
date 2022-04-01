unit DW.OTA.Types;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

type
  TBuildMode = (Clean, Compile, Build, Deploy);

  TDeployMode = (Normal, AdHoc, AppStore);

  TProjectPlatform = (Android32, Android64, iOSDevice32, iOSDevice64, {$IF CompilerVersion > 34}iOSSimulatorArm64,{$ENDIF} Linux64, macOS32, macOS64,{$IF CompilerVersion > 34} macOSArm64,{$ENDIF} Win32, Win64);

  TProjectPlatforms = set of TProjectPlatform;

  TProjectConfiguration = (Debug, Release);

  TProjectConfigurations = set of TProjectConfiguration;

implementation

end.
