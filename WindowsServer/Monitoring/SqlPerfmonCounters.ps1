Param(
  [string]$name = "MyCollectorSet",
  [string]$root = "%systemdrive%\PerfLogs\Admin\",
  [int]$duration = 0
)

$dc = New-Object -COM Pla.DataCollectorSet

$dc.DisplayName = $name;
$dc.Duration = 0;
$dc.SubdirectoryFormat = 1;
$dc.SubdirectoryFormatPattern = "yyyy\mm";
$dc.RootPath = $root + "\" + $name ;

$Dc = $dc.DataCollectors.CreateDataCollector(0)