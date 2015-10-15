@echo off&title ·�ɱ�һ������
mode con: cols=80 lines=28
:: go to batch dir
cd /D "%~dp0"

:[inte]
rem ��������֤
md latest\ipv4>nul 2>nul
md latest\ipv6>nul 2>nul
rem ���bin������������
.\bin\md5 -c609F46A341FEDEAEEC18ABF9FB7C9647 .\bin\md5.exe 2>nul||echo.���������ƺ����ƻ���, ���°�װһ������?&&ping -n 5 127.0.0.1>nul&&goto END
.\bin\md5 -c2610BF5E8228744FFEB036ABED3C88B3 .\bin\curl.exe 2>nul||echo.���������ƺ����ƻ���, ���°�װһ������?&&ping -n 5 127.0.0.1>nul&&goto END
.\bin\md5 -cC95C0A045697BE8F782C71BD46958D73 .\bin\sed.exe 2>nul||echo.���������ƺ����ƻ���, ���°�װһ������?&&ping -n 5 127.0.0.1>nul&&goto END
.\bin\md5 -c9A5E35DCB4B35A2350E6FDF4620743B6 .\bin\CCase.exe 2>nul||echo.���������ƺ����ƻ���, ���°�װһ������?&&ping -n 5 127.0.0.1>nul&&goto END

if not "%~1" == "" (
   if "%~1" == "-LOCAL" (set ST=%~1) else goto %~1
)

:[main]
rem ��ȡFTP����
title ·�ɱ�һ������: ��ȡ������...
call:[DownloadData]

rem ��֤�¾�LIST�ļ�MD5
title ·�ɱ�һ������: ��֤������...
call:[Hash_DAL]

rem ��δ����,�ӱ��ػ����ؽ����ݻ�ȡ������
:RebuildDAL
setlocal enabledelayedexpansion
cls
if defined DALmd5_lab (
   set ny=y&set /p ny=Զ������δ����,�ӱ����ؽ�һ��·�ɱ�?[Y/N]
   if "!ny!" == "y" endlocal&goto BuildCNIP
   if "!ny!" == "n" exit
   endlocal&goto RebuildDAL
)
endlocal

rem ��ȡCN����IP����
:BuildCNIP
call:[ExtractCNIPList] 4
call:[ExtractCNIPList] 6

rem ��֤�¾�IP����MD5
call:[Hash_CNIPList] 4
call:[Hash_CNIPList] 6
rem ���cnip�б�δ����,��ֱ�ӳ�ȡcnip·�ɱ����ؽ���ֱ���ؽ�·�ɱ�
if defined IPV4md5_lab if exist #Routingipv4# set IPV4RoutCache=EXIST
if defined IPV6md5_lab if exist #Routingipv6# set IPV6RoutCache=EXIST

rem ��׼��ԭʼ����
:FormatIPList
title ·�ɱ�һ������: ����������...
del /s/q "%temp%\#ipv4listLab#" >nul 2>nul
del /s/q "%temp%\#ipv6listLab#" >nul 2>nul
if not defined IPV4RoutCache null>"%temp%\#ipv4listLab#" 2>nul&start /min "·�ɱ�һ������: ����ipv4·�ɱ���..." "%~f0" [FormatIPV4List]S
if not defined IPV6RoutCache null>"%temp%\#ipv6listLab#" 2>nul&start /min "·�ɱ�һ������: ����ipv6·�ɱ���..." "%~f0" [FormatIPV6List]S
:FormatIPList_DetectLabel
rem �������ȴ���־
if exist "%temp%\#ipv4listLab#" ping /n 3 127.0.0.1>nul&goto FormatIPList_DetectLabel
if exist "%temp%\#ipv6listLab#" ping /n 3 127.0.0.1>nul&goto FormatIPList_DetectLabel

:WriteFile
rem �ϲ���������
(echo.[Local Routing]
echo.## China mainland Routing blocks
echo.## Last update: %date:~0,4%-%date:~5,2%-%date:~8,2%)>Routing.txt
rem �����б�ͷ�ļ�
call:[WriteIPHead] 4
call:[WriteIPHead] 6
rem ��������
copy /y/b Routing.txt+"%temp%\IPv4ListHead"+#Routingipv4#+"%temp%\IPv6ListHead"+#Routingipv6# Routing.txt


goto END



:[DownloadData]
if not "%ST%" == "LOCAL" (
   ping /n 1 ftp.apnic.net>nul 2>nul||echo.�޷�����������ַ��δ����...&&ping /n 3 127.0.0.1>nul&&goto END
   .\bin\curl "http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest" -o "%temp%\delegated-apnic-latest"
   copy /b/y "%temp%\delegated-apnic-latest" .\delegated-apnic-latest >nul
) else .\bin\curl "file://delegated-apnic-latest" -o "%temp%\delegated-apnic-latest" 2>nul||echo.�����ڱ����ļ�..&&ping /n 2 127.0.0.1>nul&&goto END
goto :eof

:[Hash_DAL]
setlocal enabledelayedexpansion
rem ��ȡ���ļ���MD5
for /f "delims=" %%i in ('.\bin\md5 -n "%temp%\delegated-apnic-latest"') do set DAL_newmd5=%%i
rem ��ȡ���һ�θ���ʱ��MD5
for /f "delims=." %%i in ('dir /a:-d/b ".\latest\*.md5" 2^>nul') do set DAL_oldmd5=%%i
if not defined DAL_oldmd5 set DAL_oldmd5=00000000000000000000000000000000
rem ���ݲ���Ĳ����֤
if "%DAL_oldmd5%" == "%DAL_newmd5%" (
   rem ����δ����,��־λ����
   set DALmd5_lab=EQUAL
) else (
   rem �����Ѹ���,���±��ػ���
   copy /b/y "%temp%\delegated-apnic-latest" ".\latest\%DAL_oldmd5%.md5" >nul
   ren ".\latest\%DAL_oldmd5%.md5" "%DAL_newmd5%.md5" >nul 2>nul
)
del /s/q "%temp%\delegated-apnic-latest" >nul 2>nul
for /f "tokens=1-2 delims=|" %%i in ("%DAL_newmd5%|%DALmd5_lab%") do endlocal&set DALmd5=%%i&set DALmd5_lab=%%j
goto :eof

:[ExtractCNIPList]
rem ��ȡcnip�б�
type ".\latest\%DALmd5%.md5"|findstr ipv%1|findstr CN>"%temp%\#listipv%1#"
goto :eof

:[Hash_CNIPList]
setlocal enabledelayedexpansion
rem ��ȡ���ļ���MD5
for /f "delims=" %%i in ('.\bin\md5 -n "%temp%\#listipv%1#"') do set IPV%1_newmd5=%%i
rem ��ȡ���һ�θ���ʱ��MD5
for /f "delims=." %%i in ('dir /a:-d/b ".\latest\ipv%1\*.md5" 2^>nul') do set IPV%1_oldmd5=%%i
if not defined IPV%1_oldmd5 set IPV%1_oldmd5=00000000000000000000000000000000
rem ���ݲ���Ĳ����֤
if "!IPV%1_oldmd5!" == "!IPV%1_newmd5!" (
   rem ����δ����,��־λ����
   set IPV%1md5_lab=EQUAL
) else (
   rem �����Ѹ���,���±��ػ���
   copy /b/y "%temp%\#listipv%1#" ".\latest\ipv%1\!IPV%1_oldmd5!.md5" >nul
   ren ".\latest\ipv%1\!IPV%1_oldmd5!.md5" "!IPV%1_newmd5!.md5" >nul 2>nul
)
del /s/q "%temp%\#listipv%1#" >nul 2>nul
for /f "tokens=1-2 delims=|" %%i in ("!IPV%1_newmd5!|!IPV%1md5_lab!") do endlocal&set IPV%1md5=%%i&set IPV%1md5_lab=%%j
goto :eof

:[FormatIPV6List]S
rem ��ʽ��ipv6�б�
@echo off&title ·�ɱ�һ������: ����ipv6·�ɱ���...
(for /f "tokens=4-5 delims=|" %%i in ('type ".\latest\ipv6\%IPV6md5%.md5"') do echo %%i/%%j|.\bin\ccase)>#Routingipv6#
rem ɾ�������ȴ���־
del /s/q "%temp%\#ipv6listLab#" >nul 2>nul
exit

:[FormatIPV4List]S
rem ��ʽ��ipv4�б�
@echo off&title ·�ɱ�һ������: ����ipv4·�ɱ���...
(for /f "tokens=4-5 delims=|" %%i in ('type ".\latest\ipv4\%IPV4md5%.md5"') do echo.%%i/%%j#)>#Routingipv4#
set /a index=1,indexx=2,index_out=0
set str=*&set lop=0
:[FormatIPV4List]S_LOOP
if %lop% geq 32 start /w "·�ɱ�һ������: ����ipv4·�ɱ�������..." "%~f0" [FormatIPV4List]S_ERROR&goto END
for /f "tokens=1-2 delims=/#" %%i in ('findstr /v "%str%" #Routingipv4#') do (
   set address=%%i&set /a value_mi=%%j
   call:[SearchLIB]
   set /a lop+=1
   goto [FormatIPV4List]S_LOOP
)
.\bin\sed -i "s/#//g" #Routingipv4#
goto [FormatIPV4List]S_END
:[FormatIPV4List]S_ERROR
echo.�б����δ֪����,�����˳�...
ping /n 3 127.0.0.1>nul
:[FormatIPV4List]S_END
rem ɾ�������ȴ���־
del /s/q "%temp%\#ipv4listLab#" >nul 2>nul
exit

:[SearchLIB]
for /f "tokens=1-2 delims=/" %%i in ('findstr "%value_mi%\/" Log_Lib 2^>nul') do set count=%%j
if not defined count call:[logT]
rem �滻���� /%value_mi% Ϊ /%count%
.\bin\sed -i "s/\/%value_mi%#/\/%count%#/g" #Routingipv4#
if not "%str%" == "*" (set str=%str% \/%count%#) else set str=\/%count%#
set count=
goto :eof

:[logT]
rem value_miֵ�𳬹�2^31-1Ҳ����2147483647,����2147483647����2����,ʵ����������2^30Ҳ����1073741824
:[logT][inte]
setlocal enabledelayedexpansion
if %value_mi% == 0 goto [logT][end]
if %value_mi% == 1 goto [logT][end]
:[logT][main]
if %value_mi% gtr 1 (
   set /a value_mi">>="index,index_out+=index
   if !value_mi! equ 1 goto [logT][end]
   if !value_mi! lss 1 set /a index=1,indexx=2,value_mi=%value_mi%,index_out=%index_out%&goto [logT][main]
   if !value_mi! lss !indexx! set /a index=1,indexx=2&goto [logT][main]
   if !value_mi! equ !indexx! set /a index_out+=index&goto [logT][end]
   set /a index*=2,indexx*=indexx
   goto [logT][main]
)
:[logT][end]
for /f %%s in ("%index_out%") do endlocal&set /a count=32-%%s
echo.%value_mi%/%count%>>Log_Lib
goto :eof
rem exit

:[WriteIPHead]
rem д���б�ͷ
if %1 == 4 set "port=32-log($5)/log(2)"
if %1 == 6 set "port=$5"
(echo.
echo.
echo.## IPv%1
echo.## Get the latest database from APNIC -^> "curl 'https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv%1 | grep CN | awk -F\| '{printf("%%s/%%d\n", $4, %port%)}' > Routing_IPv%1.txt"
)>"%temp%\IPv%1ListHead"
goto :eof



:END
exit
