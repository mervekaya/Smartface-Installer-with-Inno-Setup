; /////////////////////////////////////////////////////////////////////////////////////
; // Created by Merve KAYA                                                           //
; // This program makes web installer for Smartface                                  //
; // User can download missing prerequisites by choosing options on checkbox         //
; // merveekaya.93@gmail.com                                                         //
; //                                                                                 //
; /////////////////////////////////////////////////////////////////////////////////////


; *****************************************************************************************
; **                                [SETUP]                                              **
; ** In this section                                                                     **
; ** AppName : Name of application                                                       **
; ** AppVersion : Version of application                                                 **
; ** DefaultDirName : Directory name for Smartface                                       ** 
; ** LicenseFile : License file.This file must be in same directory with main(this) file.**
; ** DisableStartupPrompt : If it is writed "false" then when web installer execute ,and **
; ** user  encounter with this prompt message :                                          **
; **              "   This will install Smartface. Do you wish continue ? "              **
;******************************************************************************************

;******************************************************************************************
;**                                   [FILES]                                            **
;** In this section                                                                      **
;** Readme.txt : Install with programs to inform user.                                   **
;** smartface_4.bmp : icon of smartface.Images must have .bmp extension.                 **
;******************************************************************************************


#define MyAppName "Smartface Installer"
#define MyAppVerName "Smartface 4.2.3"
#define MyAppPublisher "Smartface, Inc."
#define MyAppURL "http://www.smartface.io/"
#define MinJRE "1.6"
#define MegaByte 1024 * 1024
#define WelcomePageCaption "Welcome to the Smartface Installation Wizard"

[Setup]
AppName=Smarface Installer      
AppVersion=4.2.3      
DefaultDirName={pf}\Smarface Installer
LicenseFile=License.txt
DefaultGroupName=Smartface
UninstallDisplayIcon={app}\Smarface Installer.exe
OutputBaseFilename=Smarface Installer
DisableStartupPrompt=true
DisableReadyPage=true
DisableDirPage=true
WizardSmallImageFile=smartface_logo.bmp
WizardImageFile=wizard.bmp
WizardSmallImageBackColor=clGreen

PrivilegesRequired=admin

; We compare the setup version information here against
; the one on the server to check for a newer version.
; So to create a new version of your installer, just
; increase these numbers
VersionInfoVersion=4.2.3
VersionInfoTextVersion=4.2.3

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Files]
Source: "Readme.txt"; DestDir: "{app}"
Source: "smartface_logo_40.bmp"; Flags: dontcopy


;List of prerequisites
[Tasks]   
Name: "Task"; Description: "Android SDK"; GroupDescription: "Prerequisites" ;  Flags: checkedonce
Name: "Task"; Description: "Itunes"; GroupDescription: "Prerequisites"; Flags: checkedonce  
Name: "Task"; Description: ".NET Framework"; GroupDescription: "Prerequisites"  ; Flags: checkedonce 
Name: "Task"; Description: "Java"; GroupDescription: "Prerequisites" ;  Flags: checkedonce



#include ReadReg(HKEY_LOCAL_MACHINE,'Software\Sherlock Software\InnoTools\Downloader','ScriptPath','');

[Code]
procedure addImage(); Forward;
function sizeOfSmartface : Cardinal; Forward;

var
  iCounter,iSizeOfArr,jCounter,kCounter,zCounter,flagForFinishPage,
  iCountOfExistFile,counter,flag,canNotDownload: Integer; 
  Page: TWizardPage;
  ResultCode: Integer;
  nameOfPreArr,nameOfPreExtArr,nameOfPreLinkArr: Array[1..4] of String;
  indexArr,isSelected,unFoundReg,notSetExe: Array[1..4] of Integer;
  smartfaceExtName,smartfaceLink,nameOfFoundPre: String;
  isRegExist : Array[1..4] of Boolean;
  FindRec: TFindRec;
                                                                                                       



procedure ExitProcess(exitCode:integer);
  external 'ExitProcess@kernel32.dll stdcall';

var progress:TOutputProgressWizardPage;



// This function was written to add images.
procedure addImage();
var
  BtnImage: TBitmapImage;     // for image
  StaticText: TNewStaticText;  //to write Smartface (350 MB) next to image
  smartfaceSize : cardinal;
  begin
  ExtractTemporaryFile('smartface_logo_40.bmp');
  BtnImage := TBitmapImage.Create(WizardForm);
  flag := 0;
  // resize text and set its position
  StaticText := TNewStaticText.Create(WizardForm);
  StaticText.Top :=  WizardForm.SelectTasksPage.Top + 55;
  smartfaceSize := sizeOfSmartface / {#MegaByte};  //to convert megabyte
  StaticText.Caption := 'Smartface App Studio ( ' + IntToStr(smartfaceSize) + ' MB )' ;
  StaticText.AutoSize := false;  //must be false to set position
  StaticText.Left := 50
  StaticText.Parent := WizardForm.SelectTasksPage;

  // resize image and set its position
  with BtnImage do 
  begin
    Parent := WizardForm.SelectTasksPage;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\')+ 'smartface_logo_40.bmp');
    AutoSize := false;    
    Width := 100;
    Height := 30;
    Top := WizardForm.SelectTasksPage.Top + 45;
    //change positon of  prerequisites list at panel
    WizardForm.TasksList.Width := WizardForm.TasksList.Width - BtnImage.Width + 100 ;
    WizardForm.TasksList.Top := WizardForm.TasksList.Top + 50 ;
          
  end;
  WizardForm.TasksList.Height := WizardForm.TasksList.Height - BtnImage.Height + 300;
end;

function sizeOfSmartface : Cardinal;
var 
  smartfaceSize : Cardinal;
  isTrue : boolean;
begin
    isTrue := ITD_GetFileSize('http://www.smartface.io/setup/SmartfaceAppStudioSetup.exe',smartfaceSize);
    Result := smartfaceSize;
end;


procedure DownloadFilesFinished(downloadPage:TWizardPage);
begin

end;


//This function downloads missing files if user selects.
function downloadFiles(): Boolean; 	
var 
  isTrue1: boolean;
  DownloadPage: TWizardPage;
  smartfaceSize,sizeOfPre : cardinal;
begin
   jCounter := jCounter - 1;
   zCounter := 1;

   For kCounter := 1 to jCounter do
   begin
      if not FileExists(ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + nameOfPreExtArr[unFoundReg[kCounter]]))then
      begin          
         itd_init;   
         ITD_SetOption('UI_DetailedMode', '1'); 
         if  (Wizardform.TasksList.Checked[unFoundReg[kCounter]] = true) then  //if user selects package
         begin 
            itd_addfile(nameOfPreLinkArr[unFoundReg[kCounter]], ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + nameOfPreExtArr[unFoundReg[kCounter]]));
         end else if (nameOfPreExtArr[unFoundReg[kCounter]] = 'dotNetFx40_Full_setup.exe') then
         begin
             canNotDownload := 1;
         end else
         begin
             canNotDownload := 3;
             notSetExe[zCounter] := unFoundReg[kCounter];
             zCounter := zCounter + 1;
         end;         
      end else 
      begin
        itd_init;   
        ITD_SetOption('UI_DetailedMode', '1'); 
        isTrue1 := ITD_GetFileSize(nameOfPreLinkArr[unFoundReg[kCounter]],sizeOfPre);
        FindFirst(ExpandConstant('{%temp}\SmartfaceInstaller\' + nameOfPreExtArr[unFoundReg[kCounter]]),FindRec);
        if  not (FindRec.SizeLow = sizeOfPre) then 
        begin
        if (Wizardform.TasksList.Checked[unFoundReg[kCounter]] = true) then
        begin
           itd_addfile(nameOfPreLinkArr[unFoundReg[kCounter]], ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + nameOfPreExtArr[unFoundReg[kCounter]]));        
        end else if(nameOfPreExtArr[unFoundReg[kCounter]] = 'dotNetFx40_Full_setup.exe') then
        begin
           canNotDownload := 1;
        end else
        begin
           canNotDownload := 3;
           notSetExe[zCounter] := unFoundReg[kCounter];
           zCounter := zCounter + 1;
         end; 
        end;         
      end;
   end;

    isTrue1 := ITD_GetFileSize(smartfaceLink,smartfaceSize);
    if not (isTrue1) then
    begin
       MsgBox('Smartface can NOT be downloaded...', mbInformation, MB_OK);
       ExitProcess(9);
    end else
    begin
      FindFirst(ExpandConstant('{%temp}\SmartfaceInstaller\' + smartfaceExtName),FindRec); 
      if  not (FindRec.SizeLow = smartfaceSize) then
      begin            
        itd_addfile(smartfaceLink, ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + smartfaceExtName));
      end ;
      DownloadPage := itd_downloadafter(wpPreparing);
      itd_afterSuccess:=@downloadFilesfinished; 
    end; 
end;

function IsJREInstalled: Boolean;
var
  JREVersion: string;
begin
  // read JRE version
  Result := RegQueryStringValue(HKLM32, 'Software\JavaSoft\Java Runtime Environment',
    'CurrentVersion', JREVersion);
  // if the previous reading failed and we're on 64-bit Windows, try to read 
  // the JRE version from WOW node
  if not Result and IsWin64 then
    Result := RegQueryStringValue(HKLM64, 'Software\JavaSoft\Java Runtime Environment',
      'CurrentVersion', JREVersion);
  // if the JRE version was read, check if it's at least the minimum one
  if Result then
    Result := CompareStr(JREVersion, '{#MinJRE}') >= 0;
end;

//This function controls whether the program was set up in computer.
//If it was set up then it will make disabled option.
//but if the program wasn't set up then it will make enable and checked option.
//If user don't want to download program , he or she can make unchecked option.
function isRegExistFunc(): Boolean;
begin

if IsWin64 then
begin
  isRegExist[1] := RegKeyExists(HKLM64,'Software\Wow6432Node\Android SDK Tools');
  isRegExist[2] := RegKeyExists(HKLM64,'Software\Wow6432Node\Apple Computer, Inc.\iTunes\');
  isRegExist[3] := RegKeyExists(HKLM64,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client');
  isRegExist[4] := RegKeyExists(HKLM64,'Software\JavaSoft\Java Runtime Environment\1.7');
 
end else 
begin
  isRegExist[1] := RegKeyExists(HKLM32,'Software\Android SDK Tools');
  isRegExist[2] := RegKeyExists(HKLM32,'Software\Apple Computer, Inc.\iTunes\');
  isRegExist[3] := RegKeyExists(HKLM32,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client');
  isRegExist[4] := RegKeyExists(HKLM32,'Software\JavaSoft\Java Runtime Environment\1.7');

end;
jCounter := 1;
   For kCounter := 1 to iSizeOfArr do
    begin
      if isRegExist[kCounter]  then
      begin
         Wizardform.TasksList.ItemEnabled[kCounter] := false;
         Wizardform.TasksList.Checked[kCounter] := false;
      end         
      else begin
        Wizardform.TasksList.ItemEnabled[kCounter] := true;
        Wizardform.TasksList.Checked[kCounter] := true;
        unFoundReg[jCounter]  := kCounter;       
        jCounter := jCounter + 1;
      end      
     end
    if IsJREInstalled then  //control all of Java versions
      begin
        Wizardform.TasksList.ItemEnabled[4] := false;
        Wizardform.TasksList.Checked[4] := false;
      end;
end;

//This function execute all downloaded files.If .Net Framework or Smartface don't set up
//then program will be terminated with error message at finish page.If other programs are not  
//set up then user can see which files are not established at finish page.
procedure executeFiles();
begin
    
  for kCounter := 1 to jCounter do
  begin
    if  (Wizardform.TasksList.Checked[unFoundReg[kCounter]] = true) then
      begin
        if  (nameOfPreExtArr[unFoundReg[kCounter]] = 'dotNetFx40_Full_setup.exe') then
        begin
          if Exec(ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + nameOfPreExtArr[unFoundReg[kCounter]] ), '', '', SW_SHOW,
              ewWaitUntilTerminated, ResultCode) then
          begin
            if ResultCode = 1602 then
            begin
              canNotDownload := 1;
            end;
          end
         end;
      end;
    end;
    
    if not (canNotDownload = 1) then
    begin
      if Exec(ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + smartfaceExtName ), '', '', SW_SHOW,
            ewWaitUntilTerminated, ResultCode) then
      begin
       if not (ResultCode = 0) then
       begin
           canNotDownload := 2;
       end;
     end
    end;
     
    if not (canNotDownload = 1) and not (canNotDownload = 2) then
    begin
      for kCounter := 1 to jCounter do
      begin
        if  Wizardform.TasksList.Checked[unFoundReg[kCounter]] = true then
          begin
            if not (nameOfPreExtArr[unFoundReg[kCounter]] = 'dotNetFx40_Full_setup.exe') then
            begin
              if  Exec(ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + nameOfPreExtArr[unFoundReg[kCounter]] ), '', '', SW_SHOW,
                  ewWaitUntilTerminated, ResultCode) then
               begin
                 if not (ResultCode = 0)   then  //Does the program was established?
                 begin
                     canNotDownload := 3;
                     notSetExe[zCounter] := unFoundReg[kCounter];
                     zCounter := zCounter + 1;
                 end;               
               end
             end;
          end;
        end;
      end;
end;
  
var
 NewInstallerPath:string;
procedure InitializeWizard();
var
  downloadPage:TWizardpage;
  returnValue : boolean;
begin

 addImage();

 WizardForm.WelcomeLabel1.Caption := '{#WelcomePageCaption}';

 itd_init;

 returnValue := CreateDir(ExpandConstant('{%temp}\' + 'SmartfaceInstaller'));
 if returnValue = false then
 begin
  ForceDirectories(ExpandConstant('{%temp}\' + 'SmartfaceInstaller'));
 end                                                  

 //Where the new installer should be saved to, can be anywhere.
 NewInstallerPath:=ExpandConstant('{%temp}\' + 'SmartfaceInstaller\' + 'SmartfaceInstaller.exe');

 {Create our own progress page for the initial download of a small
  textfile from the server which says what the latest version is}
 progress:=CreateOutputProgressPage(ITD_GetString(ITDS_Update_Caption),
    ITD_GetString(ITDS_Update_Description));



 {If the download of the new installer fails, we still want to give the
  user the option of continuing with the original installation}
 itd_setoption('UI_AllowContinue','1');


end;



procedure DownloadFinished(downloadPage:TWizardPage);
var ErrorCode:integer;
 (* text:string; *)
begin
 (*
	 Tell the user about the new installer. The message is pretty ugly if
	 NewInstallerPath is left at the default (The {tmp} directory)

	 text:=ITD_GetString(ITDS_Update_WillLaunchWithPath);

	 StringChangeEx(text, '%1', NewInstallerPath, true);

	 MsgBox(text, mbInformation, MB_OK);
 *)

 MsgBox(ITD_GetString(ITDS_Update_WillLaunch), mbInformation, MB_OK);

 if ShellExec('open', NewInstallerPath, '/updated',
   ExtractFilePath(NewInstallerPath), SW_SHOW, ewNoWait, ErrorCode) then
   ExitProcess(1);
end;

{ Compare the version string 'this' against the version string 'that'. A version
  string looks like: 1.3.2.100. Or possibly truncated: 1.3.

  Returns a positive number if this>that, 0 if this=that and a negative number
  if this<that.
}
function CompareVersions(this, that:string):integer;
var thisField, thatField:integer;
begin
 while (length(this)>0) or (length(that)>0) do begin
   if (pos('.',this)>0) then begin
     //Read the first field from the string
     thisField:=StrToIntDef(Copy(this, 1, pos('.',this)-1),0);
     //Remove the first field from the string
     this:=Copy(this, pos('.',this)+1, length(this));
   end else begin
     thisField:=StrToIntDef(this, 0);
     this:='';
   end;

   if (pos('.',that)>0) then begin
     //Read the first field from the string
     thatField:=StrToIntDef(Copy(that, 1, pos('.',that)-1),0);
     //Remove the first field from the string
     that:=Copy(that, pos('.',that)+1, length(that));
   end else begin
     thatField:=StrToIntDef(that, 0);
     that:='';
   end;

   if thisField>thatField then begin
    result:=1;
    exit;
   end else if thisField<thatField then begin
    result:=-1;
    exit;
   end;
 end;

 result:=0;
end;




function NextButtonClick(curPageID:integer):boolean;
var
 list, line:TStringList;
 newavail,isTrue:boolean;
 i:integer; 
 sizeOfSmartfaceExe: cardinal;
 ourVersion:string;
 checkedSuccessfully:boolean;
 text:string;
 downloadPage:TWizardpage;
begin
 
  Result := True;
  nameOfPreExtArr[1] := 'installer_r23.0.2-windows.exe'; // name of extensions
  if (IsWin64) then
  begin
     nameOfPreExtArr[2] := 'iTunes64Setup.exe'; 
  end else
  begin
     nameOfPreExtArr[2] := 'iTunesSetup.exe'; 
  end;
    
  nameOfPreExtArr[3] := 'dotNetFx40_Full_x86_x64.exe';
  nameOfPreExtArr[4] := 'jdk-8u11-windows-i586.exe' 
  smartfaceExtName := 'SmartfaceAppStudioSetup.exe';

  //links of prerequests
  nameOfPreLinkArr[1] := 'http://services.smartface.io/File/Download/installer_r23.0.2-windows.exe';

  if (IsWin64) then
  begin   
     nameOfPreLinkArr[2] := 'http://services.smartface.io/File/Download/iTunes64Setup.exe';
  end else
  begin
     nameOfPreLinkArr[2] := 'https://secure-appldnld.apple.com/iTunes11/031-3481.20140225.SdYYY/iTunesSetup.exe';
  end;
  nameOfPreLinkArr[3] := 'http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe';
  nameOfPreLinkArr[4] := 'http://services.smartface.io/File/Download/jdk-8u11-windows-i586.exe';
  smartfaceLink := 'http://www.smartface.io/setup/SmartfaceAppStudioSetup.exe';

  //name of prerequests
  nameOfPreArr[1] := 'Android SDK';
  nameOfPreArr[2] := 'Itunes';
  nameOfPreArr[3] := '.NET Framework';      
  nameOfPreArr[4] := 'Java';


  iSizeOfArr := 4;
  kCounter := 1;
  
 if curPageID=wpWelcome then begin

   //Are we being called by an updating setup? If so, don't ask to check for updates again!
   for i:=1 to ParamCount do begin
    if uppercase(ParamStr(i))='/UPDATED' then begin
     exit;
    end;
   end;

  wizardform.show;
  progress.Show;
  progress.SetText(ITD_GetString(ITDS_Update_Checking),'');
  progress.SetProgress(2,10);
  try
    newavail:=false;

    checkedSuccessfully:=false;
    GetVersionNumbersString(expandconstant('{srcexe}'), ourVersion);

    if itd_downloadfile('http://services.smartface.io/File/Download/latestver.txt',expandconstant('{%temp}\SmartfaceInstaller\' + 'latestver.txt'))=ITDERR_SUCCESS then begin
      { Now read the version from that file and see if it is newer.
        The file has a really simple format:

        2.0,"http://www.sherlocksoftware.org/innotools/example3%202.0.exe"

        The installer version, a comma, and the URL where the new version can be downloaded.
      }
      list:=TStringList.create;
      try
        list.loadfromfile(expandconstant('{%temp}\' + 'SmartfaceInstaller\' + 'latestver.txt'));

        if list.count>0 then begin
          line:=TStringList.create;
          try
            line.commatext:=list[0]; //Break down the line into its components

            if line.count>=2 then begin
            checkedSuccessfully:=true;
            if CompareVersions(trim(line[0]), trim(ourVersion))>0 then begin
              //Version is newer
                text:=ITD_GetString(ITDS_Update_NewAvailable);

                StringChangeEx(text, '%1', ourVersion, true); //"Current version" part of the string
                StringChangeEx(text, '%2', line[0], true); //"New version" part of the string

                if MsgBox(text, mbConfirmation, MB_YESNO)=IDYES then begin
                  isTrue := ITD_GetFileSize('Smartface%20Installer_2.exe',sizeOfSmartfaceExe);
                  if isTrue then
                  begin
                    itd_addFile('http://services.smartface.io/File/Download/Smartface%20Installer_2.exe', NewInstallerPath);
                     //Create the ITD GUI so that we have it if we decide to download a new intaller version
                    downloadPage:=itd_downloadafter(wpWelcome);
                    {If the download succeeds, we will need to launch the new installer. The
                    callback is called if the download is successful.}
                    itd_afterSuccess:=@downloadfinished;
                  end else begin
                     MsgBox('File which will be downloaded can NOT found.Exiting from setup..', mbInformation, MB_OK);
                     ExitProcess(9);
                  end;
                 end else
                 begin 
                 MsgBox('Exiting from setup..', mbInformation, MB_OK);
                 ExitProcess(9);
                 end  
            end;
            end;
          finally
            line.free;
          end;
        end;
      finally
        list.free;
      end;
    end if not checkedSuccessfully then begin
      text:=ITD_GetString(ITDS_Update_Failed);
      StringChangeEx(text, '%1', ourVersion, true);
      MsgBox(text, mbInformation, MB_OK);
    end;

  finally
    progress.Hide;
  end;
  end ;
  if CurPageID = wpSelectTasks  then
   begin       
    itd_init;   
    ITD_SetOption('UI_DetailedMode', '1');  
    downloadFiles();  
    
end;
  end;


procedure CurPageChanged(CurPageID: Integer);
var
  Index: Integer;
  missingPackages : String;
  
begin
  
  if CurPageID = wpSelectTasks  then
  begin
    isRegExistFunc();
  end; 
  if CurPageID = 12  then
  begin
      if flag = 0 then
      begin
         flag := 1;
        executeFiles();
      end
  end;
  if CurPageID = wpFinished then
  begin
   if canNotDownload = 1 then
   begin
     WizardForm.FinishedLabel.Caption := 'Since Setup .NET Framework was terminated ,Smartface can NOT be established on your computer.'#13#10''#13#10'Click Finish to exit Setup.'; 
   end
   if canNotDownload = 2 then
   begin
     WizardForm.FinishedLabel.Caption := 'Since Setup Smartface was terminated ,Smartface can NOT be established on your computer.'#13#10''#13#10'Click Finish to exit Setup.'; 
   end
   if (canNotDownload = 3) and (flagForFinishPage = 0)then
   begin
     flagForFinishPage := 1 ;
     zCounter := zCounter - 1 ;
     missingPackages := ' ';
     for kCounter := 1 to zCounter  do
     begin
       missingPackages := missingPackages + '->> ' + nameOfPreArr[notSetExe[kCounter]] + #13#10;
     end;
     WizardForm.FinishedLabel.Width := 500;
     WizardForm.FinishedLabel.Height := 700;
     WizardForm.FinishedLabel.Caption := 'Setup has finished installing Smartface on your computer..' + #13#10 +
                                         'But the following packageler was NOT established !'#13#10'' + #13#10 + missingPackages + #13#10 + #13#10 +
                                         'Click Finish to exit Setup.';                              
   end

  end;
end;


//END OF FILE



