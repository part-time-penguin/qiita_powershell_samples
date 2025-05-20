
$xml_file_name = (Get-Date).ToString("yyyyMMdd_HHmmss") + ".xml"

dxdiag.exe /x $xml_file_name
# 処理待ち
$nid = (get-process dxdiag).id
wait-process -id $nid

# UTF8指定が必要
$file_data = Get-Content -Encoding UTF8 $xml_file_name

$xml_doc = [XML]($file_data)
$xml_navigator = $xml_doc.CreateNavigator()

function print_node($path){
  $nodes = $xml_navigator.Select($path)
  While ( $nodes.MoveNext() ){
    Write-Host $nodes.Current.Name ":" $nodes.Current.Value
  }
}

# 表示したい情報をパスで指定
print_node("/DxDiag/SystemInformation/OperatingSystem")
print_node("/DxDiag/SystemInformation/Language")
print_node("/DxDiag/SystemInformation/Processor")
print_node("/DxDiag/SystemInformation/Memory")
print_node("/DxDiag/DisplayDevices/DisplayDevice/CardName")




