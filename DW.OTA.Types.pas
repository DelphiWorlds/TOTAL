unit DW.OTA.Types;

{*******************************************************}
{                                                       }
{         DelphiWorlds Open Tools API Support           }
{                                                       }
{          Copyright(c) 2018 David Nottage              }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

type
  TBuildMode = (Clean, Compile, Build, Deploy);

  TDeployMode = (Normal, AdHoc, AppStore);

  TProjectPlatform = (Android, iOSDevice32, iOSDevice64, iOSSimulator, Linux64, macOS32, macOS64, Win32, Win64);

  TProjectPlatforms = set of TProjectPlatform;

  TProjectConfiguration = (Debug, Release);

  TProjectConfigurations = set of TProjectConfiguration;

implementation

end.
