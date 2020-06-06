<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
    <Product Id="{{id}}-b1d1-4aad-a348-6bcdaa9b7d49" UpgradeCode="{{upgradeCode}}-b1d1-4aad-a348-6bcdaa9b7d49" Version="{{version}}" Language="1033" Name="{{manufacturer}} {{name}}" Manufacturer="{{manufacturer}}">
        <Package InstallerVersion="300" Compressed="yes"/>
        <Media Id="1" Cabinet="app.cab" EmbedCab="yes" />

        <MajorUpgrade DowngradeErrorMessage="A newer version of [ProductName] is already installed." MigrateFeatures="yes" />

        <Directory Id="TARGETDIR" Name="SourceDir">
            {{#is32bit}}
            <Directory Id="ProgramFilesFolder">
            {{/is32bit}}
            {{^is32bit}}
            <Directory Id="ProgramFiles64Folder">
            {{/is32bit}}
                <Directory Id="MANUFACTURERROOTDIRECTORY" Name="{{manufacturer}}">
                    <Directory Id="APPLICATIONROOTDIRECTORY" Name="{{name}}"/>
                </Directory>
            </Directory>
        </Directory>

        <Feature Id="MainApplication" Title="Main Application" Level="1">
            <ComponentGroupRef Id="STAGINGDIRECTORY" />
        </Feature>

        {{#hasPostInstall}}
        <CustomAction Id="PostInstall"
            Directory="APPLICATIONROOTDIRECTORY"
            ExeCommand="cmd /C bin\postinstall.bat"
            Execute="commit"
            Impersonate="no"
            Return="ignore" />
        {{/hasPostInstall}}

        {{#hasPreUninstall}}
        <CustomAction Id="PreUninstall"
            Directory="APPLICATIONROOTDIRECTORY"
            ExeCommand="cmd /C bin\preuninstall.bat"
            Execute="deferred"
            Impersonate="no"
            Return="ignore" />
        {{/hasPreUninstall}}

        <InstallExecuteSequence>
            {{#hasPostInstall}}
            <Custom Action="PostInstall" Before="InstallFinalize">NOT REMOVE</Custom>
            {{/hasPostInstall}}
            {{#hasPreUninstall}}
            <Custom Action="PreUninstall" Before="UnpublishFeatures">Installed</Custom>
             {{/hasPreUninstall}}
        </InstallExecuteSequence>

        <UI Id="WixUI_Minimal">
            <TextStyle Id="WixUI_Font_Normal" FaceName="Segoe UI" Size="8" />
            <TextStyle Id="WixUI_Font_Bigger" FaceName="Segoe UI" Size="12" />
            <TextStyle Id="WixUI_Font_Title" FaceName="Segoe UI" Size="9" Bold="yes" />

            <Property Id="DefaultUIFont" Value="WixUI_Font_Normal" />
            <Property Id="WixUI_Mode" Value="Minimal" />

            <DialogRef Id="ErrorDlg" />
            <DialogRef Id="FatalError" />
            <DialogRef Id="FilesInUse" />
            <DialogRef Id="MsiRMFilesInUse" />
            <DialogRef Id="PrepareDlg" />
            <DialogRef Id="ProgressDlg" />
            <DialogRef Id="ResumeDlg" />
            <DialogRef Id="UserExit" />

            <Publish Dialog="WelcomeDlg" Control="Next" Event="NewDialog" Value="VerifyReadyDlg">1</Publish> 
            <Publish Dialog="VerifyReadyDlg" Control="Back" Event="NewDialog" Value="WelcomeDlg">NOT Installed</Publish>

            <Publish Dialog="MaintenanceWelcomeDlg" Control="Next" Event="NewDialog" Value="MaintenanceTypeDlg">1</Publish>
            <Publish Dialog="MaintenanceTypeDlg" Control="RepairButton" Event="NewDialog" Value="VerifyReadyDlg">1</Publish>
            <Publish Dialog="MaintenanceTypeDlg" Control="RemoveButton" Event="NewDialog" Value="VerifyReadyDlg">1</Publish>
            <Publish Dialog="MaintenanceTypeDlg" Control="Back" Event="NewDialog" Value="MaintenanceWelcomeDlg">1</Publish>
            <Publish Dialog="VerifyReadyDlg" Control="Back" Event="NewDialog" Value="MaintenanceTypeDlg">Installed</Publish>

            <Publish Dialog="ExitDialog" Control="Finish" Event="EndDialog" Value="Return" Order="999">1</Publish>

            <Property Id="ARPNOMODIFY" Value="1" />
        </UI>

        <UIRef Id="WixUI_Common" />
    </Product>
</Wix>
