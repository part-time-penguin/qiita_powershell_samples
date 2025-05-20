[CmdletBinding(DefaultParameterSetName = 'Status')]
Param(
  [Parameter(ParameterSetName = 'Start', Mandatory = $true)]
  [Switch]$Start,
  [Parameter(ParameterSetName = 'Stop', Mandatory = $true)]
  [Switch]$Stop,
  [Parameter(ParameterSetName = 'Status', Mandatory = $false)]
  [Switch]$Status,
  [Parameter(ParameterSetName = 'Setup', Mandatory = $true)]
  [Switch]$Setup,
  [Parameter(ParameterSetName = 'Remove', Mandatory = $true)]
  [Switch]$Remove,
  # 以下は内部呼び出し用
  [Parameter(ParameterSetName = 'Service', Mandatory = $true)]
  [Switch]$Service,
  [Parameter(ParameterSetName = 'SCMStart', Mandatory = $true)]
  [Switch]$SCMStart,
  [Parameter(ParameterSetName = 'SCMStop', Mandatory = $true)]
  [Switch]$SCMStop
)

$ps1Info = Get-Item $MyInvocation.MyCommand.Definition
$scriptPath = $ps1Info.fullname
$scriptDir = $ps1Info.DirectoryName
$serviceName = $ps1Info.basename  # TODO サービス名
$serviceDisplayName = "PowerShell Service Template" # TODO サービスの説明
$exePath = "$scriptDir\$serviceName.exe"
$logPath = "$scriptDir\$serviceName.log"
$exitEventName = "Global\Event_ServiceTemplate_exit"  # TODO 複数サービス登録する場合は重複しないように書き換える

#-----------------------------------------------------------------------------#
# CSharp - Service Source Code 
$execScriptPath = $scriptPath -replace "\\", "\\"
$serviceSource_cs = @"
using System;
using System.Diagnostics;
using System.ServiceProcess;

public class ServiceTemplate : ServiceBase {   
  private void ExecuteProcess(string executePath , string param){
    Process p = new Process();
    p.StartInfo.UseShellExecute = false;
    p.StartInfo.RedirectStandardOutput = false;
    p.StartInfo.FileName = executePath;
    p.StartInfo.Arguments = param;
    p.Start();
    p.WaitForExit();
  }
  protected override void OnStart(string [] args) {
      ExecuteProcess("PowerShell.exe", "-ExecutionPolicy Bypass -c & '$execScriptPath' -SCMStart");
  }
  protected override void OnStop() {
      ExecuteProcess("PowerShell.exe", "-ExecutionPolicy Bypass -c & '$execScriptPath' -SCMStop");
  }
  public static void Main() {
      ServiceBase.Run(new ServiceTemplate());
  }
}
"@

#-----------------------------------------------------------------------------#
# event functions
Function Send-ServiceEvent () { 
  Param(
    [Parameter(Mandatory = $true)]
    [String]$EventName
  )
  [System.Threading.EventWaitHandle]::OpenExisting($EventName).set()
}

Function wait-ServiceEvent () {
  Param(
    [Parameter(Mandatory = $true)]
    [String]$EventName,
    [Parameter(Mandatory = $false)]
    [String]$Timeout = -1
  )
  $serviceEvent = New-Object -TypeName System.Threading.EventWaitHandle -ArgumentList $false, 0, $EventName
  $serviceEvent.WaitOne($Timeout, $false)
}

#-----------------------------------------------------------------------------#
# Service Script Main
$Status = ($PSCmdlet.ParameterSetName -eq 'Status')
if ($Start) {
  Start-Service $serviceName
}
if ($Stop) {
  Stop-Service $serviceName
}
if ($Status) {
  try {
    $sv = Get-Service $serviceName -ea stop
    $sv.Status
  }
  catch {
    "Not Installed"
  }
}
if ($Setup) {
  try {
    Get-Service $serviceName -ea stop > $null
    exit 0
  }
  catch {
  }
  try {
    Add-Type -TypeDefinition $serviceSource_cs -Language CSharp -OutputAssembly $exePath -OutputType ConsoleApplication -ReferencedAssemblies "System.ServiceProcess" -Debug:$false
    New-Service $serviceName $exePath -DisplayName $serviceDisplayName -StartupType Automatic > $null
  }
  catch {
    $_.Exception.Message
  }
}
if ($Remove) {
  try {
    Get-Service $serviceName -ea stop > $null
    Stop-Service $serviceName
    sc.exe delete $serviceName > $null
  }
  catch {
    $_.Exception.Message
  }
}
if ($SCMStart) {
  Start-Process PowerShell.exe -ArgumentList ("-c & '$scriptPath' -Service")
}
if ($SCMStop) {
  Send-ServiceEvent $exitEventName
}
if ($Service) {
  try {
    $timeout = 10 * 1000  # TODO 実行間隔(ミリ秒)
    do {
      # TODO カスタムする処理をここに記載する
      $logString = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
      $logString | Out-File "$logPath" -Encoding utf8 -Append 

      $signale = wait-ServiceEvent $exitEventName $timeout
    } while ($signale -eq $false)
  }
  catch {
    $_.Exception.Message
  }
}

