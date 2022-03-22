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

  TProjectPlatform = (Android32, Android64, iOSDevice32, iOSDevice64, iOSSimulatorArm64, Linux64, macOS32, macOS64, macOSArm64, Win32, Win64);

  TProjectPlatforms = set of TProjectPlatform;

  TProjectConfiguration = (Debug, Release);

  TProjectConfigurations = set of TProjectConfiguration;

implementation

end.
