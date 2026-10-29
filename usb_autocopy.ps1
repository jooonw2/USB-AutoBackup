# Carpeta base de backups
$backupBase = "C:\USBBackups"

# Asegurar que exista
if (!(Test-Path -Path $backupBase)) {
    New-Item -Path $backupBase -ItemType Directory
}

# Función para copiar contenido y generar logs
function Copy-USBContent {
    param (
        [string]$sourceDrive,
        [string]$label,
        [string]$fileSystem,
        [uint64]$size,
        [uint64]$freeSpace
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $folderName = "$($label)_$timestamp"
    $destination = Join-Path -Path $backupBase -ChildPath $folderName
    New-Item -Path $destination -ItemType Directory | Out-Null

    # Medir tiempo de inicio
    $startTime = Get-Date

    # Obtener todos los archivos (incluso ocultos y de sistema), ordenados por tamaño
    $files = Get-ChildItem -Path "$sourceDrive\" -Recurse -File -Force -ErrorAction SilentlyContinue | Sort-Object Length

    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($sourceDrive.Length)
        $targetPath = Join-Path $destination $relativePath
        $targetDir = Split-Path $targetPath

        if (!(Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        }

        Copy-Item -Path $file.FullName -Destination $targetPath -Force -ErrorAction SilentlyContinue
    }

    # Medir tiempo total
    $endTime = Get-Date
    $elapsedTime = $endTime - $startTime
    $elapsedSeconds = [math]::Round($elapsedTime.TotalSeconds, 2)

    # Generar resumen de tipos de archivo
    $summary = $files | Group-Object Extension | Sort-Object Count -Descending | ForEach-Object {
        "{0,-10} {1,5} archivos" -f $_.Name, $_.Count
    }

    # Guardar información del USB y del proceso
    $infoPath = Join-Path $destination "info_usb.txt"

    $usbInfo = @"
Fecha/Hora:       $(Get-Date)
Unidad:           $sourceDrive
Etiqueta:         $label
Sistema de Arch.: $fileSystem
Tamaño Total:     $([math]::Round($size / 1GB, 2)) GB
Espacio Libre:    $([math]::Round($freeSpace / 1GB, 2)) GB
Total Archivos:   $($files.Count)
Tiempo Copia:     $elapsedSeconds segundos
Destino Backup:   $destination

Resumen por tipo de archivo:
-----------------------------
$($summary -join "`n")
"@

    $usbInfo | Out-File -FilePath $infoPath -Encoding UTF8
}

# Monitor de conexión USB
Register-WmiEvent -Class Win32_VolumeChangeEvent -Action {
    $event = $Event.SourceEventArgs.NewEvent
    if ($event.EventType -eq 2) {
        Start-Sleep -Seconds 2  # Esperar montaje

        $usb = Get-WmiObject Win32_Volume | Where-Object { $_.DriveType -eq 2 -and $_.DriveLetter -ne $null } | Select-Object -First 1

        if ($usb) {
            $driveLetter = $usb.DriveLetter
            $label = if ($usb.Label) { $usb.Label } else { "USB" }
            $fileSystem = $usb.FileSystem
            $size = $usb.Capacity
            $free = $usb.FreeSpace

            Copy-USBContent -sourceDrive "$driveLetter\" -label $label -fileSystem $fileSystem -size $size -freeSpace $free
        }
    }
}

# Mantener el script vivo para escuchar eventos
Write-Output "⏳ Esperando conexión de dispositivos USB... (Ctrl + C para salir)"

while ($true) {
    Start-Sleep -Seconds 10
}

