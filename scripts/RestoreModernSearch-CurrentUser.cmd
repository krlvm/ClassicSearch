@echo off
reg delete "HKCU\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}" /f
reg delete "HKCU\Software\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}" /f