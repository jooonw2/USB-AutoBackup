
# USB-AutoBackup

Script desarrollado en **PowerShell** para automatizar las copias de seguridad de dispositivos USB en Windows.

Cuando se conecta un USB, el script detecta el evento e inicia la copia de sus archivos a una carpeta local. También genera un informe con información del dispositivo y del proceso.

## Características

- Detección de conexiones USB mediante WMI.
- Copia recursiva de archivos y subcarpetas.
- Inclusión de archivos ocultos accesibles.
- Creación de carpetas con fecha y hora.
- Generación de informes con información del USB, número de archivos, tiempo de copia y resumen por extensiones.

## Tecnologías utilizadas

- PowerShell
- Windows
- WMI (Windows Management Instrumentation)

## Instalación y uso

Clona el repositorio:

```bash
git clone https://github.com/jooonw2/USB-AutoBackup.git
cd USB-AutoBackup
```

Configura la carpeta de destino modificando la variable `$backupBase` del script. Por defecto, las copias se guardan en `C:\USBBackups`.

Ejecuta el script desde PowerShell:

```powershell
.\usb_autocopy.ps1
```

El script permanecerá activo escuchando conexiones USB. Para detenerlo, pulsa `Ctrl + C`.

## Ejemplo de resultado

```text
C:\USBBackups\
└── MI_USB_20261028_120000\
    ├── documento.pdf
    ├── imagen.jpg
    └── info_usb.txt
```

El archivo `info_usb.txt` contiene información del dispositivo y estadísticas del proceso de copia.

## Limitaciones

Esta versión inicial puede seleccionar una unidad distinta de la recién conectada y no registra individualmente todos los errores de copia. Tampoco verifica la integridad de los archivos mediante hashes.

## Uso responsable

Utiliza este script únicamente con dispositivos propios o con autorización para acceder a su contenido. Protege los respaldos que contengan información sensible.
