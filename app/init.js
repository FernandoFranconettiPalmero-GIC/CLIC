/* --- Instanciamos objetos con capacidad de manipular directorios y correr scripts --- */
var $shell            = new ActiveXObject("WScript.Shell");
var $fileSystemObject = new ActiveXObject("Scripting.FileSystemObject");

/* --- Obtenemos la ruta de este script y desde ahí conseguimos la ruta de selectorLifter.ps1 --- */
var $pathInit     = $fileSystemObject.GetParentFolderName(WScript.ScriptFullName);
var $pathSelector = $fileSystemObject.BuildPath($pathInit, "script/powershell/selectorLifter.ps1");

/* --- Ejecutamos selectorLifter.ps1 --- */
$shell.Run('powershell.exe -ExecutionPolicy Bypass -NoProfile -File "' + $pathSelector + '" -pathInit "' + $pathInit + '"');