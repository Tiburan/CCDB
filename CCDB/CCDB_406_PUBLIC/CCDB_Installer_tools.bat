@ECHO OFF
TITLE Catacrunch DB Project Tools
COLOR 0b
SET build_ver= G5 (4.0.6a)
SET updatetime= Dec 18,2011 6:34pm
SET dbrev= CCDB R14

:TOP
CLS
ECHO.
ECHO                 CCDB PUBLIC RELEASE
ECHO. 
ECHO          ��������������������������������ͻ
ECHO          �                                �
ECHO          �   CC-DB-P installation tools   �
ECHO          �                                �
ECHO          �              for               �
ECHO          �                                �
ECHO          �     Ultracore%build_ver%      �
ECHO          �             and                �
ECHO          �         Skyfire Core           �
ECHO          �                                �
ECHO          �       DB version%dbrev%      �
ECHO          �                                �
ECHO          �  Updated on%updatetime% �
ECHO          �                                �
ECHO          ��������������������������������ͼ
ECHO.
ECHO   Project Members: Catacrunch, Lorac, Nomad, Zamara, Sulbutx, 
ECHO                    John2308, Prydev, Tiburan, Raydeon
ECHO   2011 Catacrunch DB Development Project
ECHO.
PAUSE
CLS
COLOR 0C
ECHO    Please enter your MySQL Info...
ECHO.
SET /p host= First enter MySQL Server Address (e.g. localhost):
ECHO.
SET /p user= Now your MySQL Username: 
SET /p pass= and MySQL Password: 
cls
SET /p world_db= Ok now enter your World Database:
Cls
SET /P char_db= and finally your Character Database:
SET port=3306
SET cdumppath=.\db_backups\character_dump\
SET wdumppath=.\db_backups\world_dump\
SET mysqlpath=.\database\dep\mysql\
SET devcsql=.\database\main_db\character\
SET devsql=.\database\main_db\world\
SET procsql=.\database\main_db\procs\
SET changsql=.\database\development\core_updates
SET update_pack=.\database\development\update_pack
SET dev_pack=.\database\development\dev_pack
SET community_pack .\development\community_packs
SET local_sp=.\database\development\locals\spanish\
SET local_gr=.\database\development\locals\german\
SET local_ru=.\database\development\locals\russian\
SET local_it=.\database\development\locals\italian\

:Begin
CLS
SET upstat=No Updates
Set lstat=Under Development
COLOR 0b
SET v=""
ECHO.
ECHO.
ECHO.
ECHO.
ECHO          ������������������������������������������������ͻ
ECHO          �                                                �
ECHO          �        Please Choose an option                 �
ECHO          �                                                �
ECHO          �  1. Install DB Note: This will wipe old DB!    �
ECHO          �                                                �
ECHO          �  2. Apply Updates             %upstat%       �
ECHO          �                                                �
ECHO          �  3. Backup World DB                            �
ECHO          �                                                �
ECHO          �  4. Backup Character DB                        �
ECHO          �                                                �
ECHO          �  5. Install empty Char DB                      �
ECHO          �                                                �
ECHO          �  5. Apply Locals            %lstat%  �
ECHO          �                                                �
ECHO          �  7. Change Settings                            �
ECHO          �                                                �
ECHO          �  X  Exit Install tool                          �
ECHO          �                                                �
ECHO          ������������������������������������������������ͼ
ECHO.
ECHO.

SET /p v= 		Enter a char: 
IF %v%==* GOTO error
IF %v%==1 GOTO import_world
IF %v%==2 GOTO updates
IF %v%==3 GOTO dump_world
IF %v%==4 GOTO dump_char
IF %v%==5 GOTO import_char
IF %v%==6 GOTO begin
IF %v%==7 GOTO top
REM IF %v%==5 GOTO locals

IF %v%==x GOTO exit
IF %v%==X GOTO exit
IF %v%=="" GOTO exit
GOTO error

:import_world
CLS
ECHO First Lets Create database (or overwrite old) !!
ECHO.
ECHO DROP database IF EXISTS `%world_db%`; > %devsql%\databaseclean.sql
ECHO CREATE database IF NOT EXISTS `%world_db%`; >> %devsql%\databaseclean.sql
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% < %devsql%\databaseclean.sql
@DEL %devsql%\databaseclean.sql

ECHO Lets make a clean database.
ECHO Importing new DB Data now...
ECHO.
ECHO. Adding Stored Procedures
for %%C in (%procsql%\*.sql) do (
	ECHO import: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
)
ECHO Stored Procedures imported sucesfully!
ECHO.
ECHO Installing World Data
FOR %%C IN (%devsql%\*.sql) DO (
	ECHO Importing: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
	ECHO Successfully imported %%~nxC
)
ECHO.
ECHO import: Critical Updates
for %%C in (%changsql%\*.sql) do (
	ECHO import: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
)
ECHO Updates imported sucesfully!
ECHO.
ECHO Your Installation is complete your current db is CCDB-P version %dbrev% 
ECHO.
ECHO Thank you for using CCDB, Enjoy
ECHO.
ECHO.
PAUSE
GOTO Begin



:import_char
CLS
ECHO First Lets Create database (or overwrite old) !!
ECHO.
ECHO DROP database IF EXISTS `%char_db%`; > %devcsql%\databaseclean.sql
ECHO CREATE database IF NOT EXISTS `%char_db%`; >> %devcsql%\databaseclean.sql
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% < %devcsql%\databaseclean.sql
@DEL %devcsql%\databaseclean.sql

ECHO Lets make a clean database.
ECHO Importing Data now...
ECHO.
ECHO.
ECHO Installing Character Data
FOR %%C IN (%devcsql%\*.sql) DO (
	ECHO Importing: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %char_db% < "%%~fC"
	ECHO Successfully imported %%~nxC
)
ECHO.
ECHO    You now have a clean character db
ECHO.
ECHO.
ECHO.
ECHO.
PAUSE
GOTO Begin






:dump_world
CLS
IF NOT EXIST "%dumppath%" MKDIR %wdumppath%
ECHO %world_db% Database Export started...

FOR %%a IN ("%devsql%\*.sql") DO SET /A Count+=1
setlocal enabledelayedexpansion
FOR %%C IN (%devsql%\*.sql) DO (
	SET /A Count2+=1
	ECHO Dumping [!Count2!/%Count%] %%~nC
	%mysqlpath%\mysqldump --host=%host% --user=%user% --password=%pass% --port=%port% --skip-comments %world_db% %%~nC > %wdumppath%\%%~nxC
)
endlocal 

ECHO  Finished ... %world_db% exported to %wdumppath% folder...
PAUSE
GOTO begin

:dump_char
CLS
IF NOT EXIST "%cdumppath%" MKDIR %cdumppath%
ECHO %char_db% Database Export started...

FOR %%a IN ("%devcsql%\*.sql") DO SET /A Count+=1
setlocal enabledelayedexpansion
FOR %%C IN (%devcsql%\*.sql) DO (
	SET /A Count2+=1
	ECHO Dumping [!Count2!/%Count%] %%~nC
	%mysqlpath%\mysqldump --host=%host% --user=%user% --password=%pass% --port=%port% --skip-comments %char_db% %%~nC > %cdumppath%\%%~nxC
)
endlocal 

ECHO  Finished ... %char_db% exported to %cdumppath% folder...
PAUSE
GOTO begin

:locals
CLS
ECHO          ������������������������������������������������ͻ
ECHO          �                                                �
ECHO          �      Please select your language               �
ECHO          �                                                �
ECHO          �     S.          Spanish   "Some Data Applied"  �
ECHO          �                                                �
ECHO          �     G.          German    "No Data Yet"        �
ECHO          �                                                �
ECHO          �     R.          Russian   "No Data Yet"        �
ECHO          �                                                �
ECHO          �     I.          Italian   "Some Data Applied"  �
ECHO          �                                                �
ECHO          �     F.          French    "Some Data Applied"  �
ECHO          �                                                �
ECHO          �     B.          Main Menu                      �
ECHO          �                                                �
ECHO          ������������������������������������������������ͼ
ECHO.
set /p ch=      Letter: 
ECHO.
IF %ch%==s GOTO install_sp
IF %ch%==S GOTO install_sp
IF %ch%==g GOTO install_gr
IF %ch%==G GOTO install_gr
IF %ch%==r GOTO install_ru
IF %ch%==R GOTO install_ru
IF %ch%==i GOTO install_it
IF %ch%==I GOTO install_it
IF %ch%==f GOTO install_fr
IF %ch%==F GOTO install_fr
IF %ch%==b GOTO begin
IF %ch%==B GOTO begin
IF %ch%=="" GOTO locals
GOTO error

:install_sp
ECHO Importing Spanish Data now...
ECHO.
FOR %%C IN (%local_sp%\*.sql) DO (
	ECHO Importing: %%~nxC1
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
	ECHO Spanish Locals Successfully imported %%~nxC1
)
ECHO Done.
GOTO Begin

:install_gr
ECHO Importing German Data now...
ECHO.
FOR %%C IN (%local_sp%\*.sql) DO (
	ECHO Importing: %%~nxC1
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
	ECHO German Locals Successfully imported %%~nxC1
)
ECHO Done.
GOTO Begin

:install_ru
ECHO Importing Russian Data now...
ECHO.
FOR %%C IN (%local_sp%\*.sql) DO (
	ECHO Importing: %%~nxC1
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
	ECHO Russian Locals Successfully imported %%~nxC1
)
ECHO Done.
GOTO Begin

:install_it
ECHO Importing Italian Data now...
ECHO.
FOR %%C IN (%local_it%\*.sql) DO (
	ECHO Importing: %%~nxC1
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
	ECHO Italian Locals Successfully imported %%~nxC1
)
ECHO Done.
GOTO Begin

:install_fr
ECHO Importing French Data now...
ECHO.
FOR %%C IN (%local_fr%\*.sql) DO (
	ECHO Importing: %%~nxC1
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
	ECHO French Locals Successfully imported %%~nxC1
)
ECHO Done.
GOTO Begin

:dumpchar
CLS
SET sqlname=char-%DATE:~0,3% - %DATE:~4,2%-%DATE:~7,2%-%DATE:~10,4%--%TIME:~0,2%-%TIME:~3,2%
SET /p chardb=   Enter name of your character DB:
ECHO.
IF NOT EXIST "%dumppath%" MKDIR %dumppath%
ECHO Dumping %sqlname%.sql to %dumppath%
%mysqlpath%\mysqldump -u%user% -p%pass% --routines --skip-comments --result-file="%dumppath%\%sqlname%.sql" %chardb%
ECHO Done.
PAUSE
GOTO begin

:Updates
CLS
ECHO.
ECHO.   
ECHO.
ECHO          ������������������������������������������������ͻ
ECHO          �                                                �
ECHO          �      Please select your Choice                 �
ECHO          �                                                �
ECHO          �     1.          Core Updates                   �
ECHO          �                                                �
ECHO          �     2.          Dev Hot Fixes                  �
ECHO          �                                                �
ECHO          �     3.          Community Fixes                �
ECHO          �                                                �
ECHO          �     4.          DB UpdatePack                  �
ECHO          �                                                �
ECHO          �     5.          Main Menu                      �
ECHO          �                                                �
ECHO          ������������������������������������������������ͼ
ECHO.
ECHO.
set /p ch=      Number: 
ECHO.
IF %ch%==1 GOTO core_update
IF %ch%==2 GOTO dev_fix
IF %ch%==3 GOTO com_fix
IF %ch%==4 GOTO Up_pack
IF %ch%==5 GOTO begin
IF %ch%=="" GOTO Updates
GOTO error


:core_update
CLS
ECHO.
ECHO import: Core Changesets
for %%C in (%changsql%\*.sql) do (
	ECHO import: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
)
ECHO Changesets imported sucesfully!
ECHO.
PAUSE   
GOTO begin

:dev_fix
CLS
ECHO.
ECHO import: Developer Hotfixes
for %%C in (%dev_pack%\*.sql) do (
	ECHO import: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
)
ECHO Hotfixes imported sucesfully!
ECHO.
PAUSE   
GOTO begin

:com_fix
CLS
ECHO.
ECHO import: community fixes
for %%C in (%com_pack%\*.sql) do (
	ECHO import: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
)
ECHO Community fixes imported sucesfully!
ECHO.
PAUSE   
GOTO begin

:up_pack
CLS
ECHO.
ECHO import: update pack
for %%C in (%update_pack%\*.sql) do (
	ECHO import: %%~nxC
	%mysqlpath%\mysql --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% < "%%~fC"
)
ECHO Update Pack imported sucesfully!
ECHO.
PAUSE   
GOTO begin

:error
ECHO	Please enter a correct character.
ECHO.
PAUSE
GOTO begin

:error2
ECHO	Changeset with this number not found.
ECHO.
PAUSE
GOTO begin

:exit