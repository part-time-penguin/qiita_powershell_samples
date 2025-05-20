Set-Location -Path $PSScriptRoot

Add-Type -Path ".\log4net.dll" # パスは環境に合わせて変更

$logger = [log4net.LogManager]::GetLogger($MyInvocation.MyCommand.Path)

$Appender = new-object log4net.Appender.RollingFileAppender
$Appender.File = ([System.IO.Directory]::GetParent($MyInvocation.MyCommand.Path)).FullName + "\sample.log" # フルパス指定が重要
$Appender.Encoding= [System.Text.Encoding]::UTF8
$Appender.Threshold = [log4net.Core.Level]::Debug
$Appender.AppendToFile = $True
$Appender.StaticLogFileName = $True
$Appender.PreserveLogFileNameExtension = $True

# モードを指定 Size or Date(or Composite)
$Appender.RollingStyle = [log4net.Appender.RollingFileAppender+RollingMode]::Composite  # ここの指定方法でハマった

# RollingMode::Size (or Composite) の設定
$Appender.MaxSizeRollBackups = 5
$Appender.MaxFileSize = 1024 * 1024 * 10 # 10MB
$Appender.CountDirection = -1 # -1だと常に同じファイル名

# RollingMode::Date (or Composite)  の設定
$Appender.DatePattern = ".yyyyMMdd"

$layout = new-object log4net.Layout.PatternLayout
$layout.ConversionPattern = "%date{yyyy/MM/dd HH:mm:ss.fff},%-5p,%m%n"

$Appender.Layout = $layout
$Appender.ActivateOptions()
$logger.Logger.AddAppender($Appender)
$logger.Logger.Hierarchy.Configured = $True # 設定を有効にする

for($index = 0 ; $index -lt 100 ; $index++){

    $logger.Debug("Debug メッセージ " + $index )
    $logger.Info("Info メッセージ " + $index )
    $logger.Warn("Warn メッセージ " + $index )
    $logger.Error("Error メッセージ " + $index )
    $logger.Fatal("Fatal メッセージ " + $index )
}

[log4net.LogManager]::ResetConfiguration()  # ResetConfiguration()でファイルクローズできます


