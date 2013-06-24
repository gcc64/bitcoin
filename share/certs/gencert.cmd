@echo off

:: gencert.cmd: used to generate self-signed private certificates

:: so that SSL can be used locally by other programs

:: for secure argument passing to bitcoin...

::

:: NOTE: WHEN PROMPTED, CHOOSE A FQDN THAT YOU WILL BE REFERNCING IN YOUR URL!

::

:: Example:       https://localhost

:: FQDN would be: localhost

::

:: This work is free software; you can redistribute it and/or modify it

:: under the terms of the GNU Lesser General Public License as published

:: by the Free Software Foundation; either version 2.1 of the License,

:: or (at your option) any later version.

::

:: This work is distributed in the hope that it will be useful,

:: but without any warranty; without even the implied warranty

:: of merchantability or fitness for a particular purpose.

:: See the GNU Lesser General Public License for more details.

:: You should have received a copy of the GNU Lesser General Public License

:: along with this library; if not, write to the Free Software Foundation, Inc.,

:: 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

::


set DOWNLOADS_URL=http://slproweb.com/products/Win32OpenSSL.html

set DATA_DIR=%APPDATA%\Bitcoin

set PRIVATE_KEY_FILE=server.pem

set CERT_CHAIN_FILE=server.cert

set RSA_KEY_LENGTH=2048

set LifETIME_YEARS=10

set /a LifETIME_DAYS=365*%LifETIME_YEARS%



if Not "%1" == "" set DATA_DIR=%1

if Not "%2" == "" set CERT_CHAIN_FILE=%2

if Not "%3" == "" set PRIVATE_KEY_FILE=%3



openssl version 2>nul: |findstr OpenSSL >nul: && goto Check_Dir

echo This script requires that OpenSSL be installed;

echo also be sure to include the install directory of OpenSSL

echo to your "PATH" variable (Control Panel, System...

echo Advanced System Settings, Environment Variables, System Variables...)

echo.

echo After editing your system's PATH variable you will need

echo to start a new "Command Prompt" session or reboot...

echo.

set /P LAUNCH=Do you want me to open the web page for OpenSSL downloads? ([Y]/N) 

if /I "%LAUNCH%" == "Y" start "" "%DOWNLOADS_URL%"

goto exit



:Check_Dir

if Exist "%DATA_DIR%" goto CD

echo Bitcoin install directory "%DATA_DIR%" does not exist;

echo terminating...

goto exit



:CD

cd "%DATA_DIR%"



if Not Exist "%PRIVATE_KEY_FILE%" goto genrsa

set /P OVERWRITE='%PRIVATE_KEY_FILE%' already exists; overwrite? (Y/[N]) 

if /I Not "%OVERWRITE%" == "Y" goto chain

del /F /Q "%PRIVATE_KEY_FILE%"

if Not Exist "%PRIVATE_KEY_FILE%" goto genrsa

echo error deleting; terminating...

goto exit



:genrsa

openssl genrsa -out "%PRIVATE_KEY_FILE%" %RSA_KEY_LENGTH%



:chain

if Not Exist "%CERT_CHAIN_FILE%" goto new

set /P OVERWRITE='%CERT_CHAIN_FILE%' already exists; overwrite? (Y/[N]) 

if /I Not "%OVERWRITE%" == "Y" goto exit

del /F /Q "%CERT_CHAIN_FILE%"

if Not Exist "%CERT_CHAIN_FILE%" goto new

echo error deleting; terminating...

goto exit



:new

openssl req -new -x509 -nodes -sha1 -days %LifETIME_DAYS% -key "%PRIVATE_KEY_FILE%" > "%CERT_CHAIN_FILE%"

:exit
