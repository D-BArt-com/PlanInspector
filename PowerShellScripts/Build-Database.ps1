#==================================================================================================
#Read variables from xml file
#==================================================================================================
try
{
  $XmlLocation    = ".\PowerShellScripts\Variables.xml"
  [xml]$Variables = Get-Content $XmlLocation -ErrorAction Stop
  $ServerName     = $Variables.General.ServerName
  $DbName         = $Variables.General.DbName
  $DDLFile        = $Variables.General.DDLFile
}
catch
{
  $Error[0] | Format-List -force
  Throw
}
$StartTime = Get-Date

#==================================================================================================
#Drop and create output database.
#==================================================================================================
$Query =" USE master;
          GO
          
          IF EXISTS (SELECT * FROM sys.databases WHERE [name] = '$DbName')
          BEGIN
            DECLARE @sql NVARCHAR(MAX) = N'';
            DECLARE @spid INT;
            /* build and execute KILL statements for every other SPID using that DB */
            SELECT @sql = STRING_AGG(N'KILL ' + CONVERT(varchar(5), session_id) + N';', CHAR(13))
            FROM 
              sys.dm_exec_sessions
            WHERE 
              database_id = DB_ID('$DbName')
            AND 
            session_id <> @@SPID;  /* don’t kill yourself */

            IF @sql IS NOT NULL
            BEGIN
              EXEC sys.sp_executesql @sql;
            END
            ALTER DATABASE [$DbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
            DROP DATABASE  [$DbName];
          END;
          CREATE DATABASE [$DbName];
          ALTER DATABASE  [$DbName] SET RECOVERY SIMPLE WITH NO_WAIT;"
try 
{
  Invoke-SqlCmd -TrustServerCertificate -ServerInstance $ServerName -Database master -Query $Query -ErrorAction Stop
}
catch 
{
  $Error[0] | Format-List -force
  Throw
}
#==================================================================================================
#Execute the create script.  
#==================================================================================================
try
{
  Invoke-SqlCmd -TrustServerCertificate -ServerInstance $ServerName -Database $DbName -InputFile $DDLFile -ErrorAction Stop 
}
catch 
{
  $Error[0] | Format-List -force
  Throw
}
#==================================================================================================
#End of general script
#==================================================================================================
$EndTime = Get-Date
New-TimeSpan -Start $StartTime -End $EndTime | Select-Object -Property totalminutes, totalSeconds | Format-List
Write-Output "End of script."