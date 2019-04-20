DECLARE @TableName VARCHAR(255)
DECLARE @PrintTableName VARCHAR(255)
DECLARE @Template VARCHAR(8000)

SET @TableName = 'Orders'
SET @PrintTableName = 'Order'
SET @Template = '
** Generate simple list of table columns /v1.0
$table: {loop}$field{sap}, {/sap}{/loop}
'

/*********************************************************************\
* TSqlCodeGen {Version: 2.0}
*
* (C) 2007-2019 Firoz Ansari. http://www.firozansari.com
*
* Permission to use, copy, modify, and distribute this software for any
* purpose with or without fee is hereby granted, provided that the above
* copyright notice and this permission notice appear in all copies.
*
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
* WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS.
*
* Tags Help:
* $table    : Table name
* $field    : Column Name
* $type     : .NET Data Type
* $sp_type  : SQL Data Type
* $default  : .NET Default Value
* $length   : Column 8000 Length
*
* {loop}    : Start Loop Tag
* {/loop}   : End Loop Tag
*
* {sap}		  : Separator Start Tag
* {/sap}	  : Separator End Tag
\*********************************************************************/

SET NOCOUNT ON
DECLARE @ColumnName VARCHAR(255)
DECLARE @DataType VARCHAR(255)
DECLARE @MaxLength INT
DECLARE @IsNull INT
DECLARE @RType VARCHAR(100)
DECLARE @RDefault VARCHAR(100)
DECLARE @Snippet VARCHAR(8000)
DECLARE @TempSnippet VARCHAR(8000)
DECLARE @RenderedSnippet VARCHAR(8000)

DECLARE @TotalColumn INT
DECLARE @SapCount INT
DECLARE @StartSap VARCHAR(10)
DECLARE @EndSap VARCHAR(10)

DECLARE @CurrentPos INT
DECLARE @StartTag VARCHAR(10)
DECLARE @EndTag VARCHAR(10)
DECLARE @StartPos INT
DECLARE @EndPos INT

DECLARE CurColumnList CURSOR FOR
SELECT [Column].Name AS [ColumnName], systypes.Name AS [DateType], [Column].max_length as [MaxLength], [Column].is_nullable as [IsNull]
FROM Sys.Columns [Column]
INNER JOIN SysTypes ON [Column].system_type_id = SysTypes.xtype
LEFT JOIN SysComments ON [Column].default_object_id = SysComments.id
LEFT OUTER JOIN sys.extended_properties ex ON ex.major_id = [Column].object_id AND ex.minor_id = [Column].column_id AND ex.name = 'MS_Description'
WHERE OBJECTPROPERTY([Column].object_id, 'IsMsShipped')=0 AND systypes.Name!='sysname'
AND OBJECT_NAME([Column].object_id) = @TableName
ORDER BY OBJECT_NAME([Column].object_id), [Column].column_id

SELECT @TotalColumn=COUNT(*)
FROM SYSCOLUMNS col
INNER JOIN SYSOBJECTS obj ON col.ID = obj.ID AND obj.xtype='U'
WHERE obj.name=@TableName

SET @StartTag = '{loop}'
SET @EndTag = '{/loop}'

SET @StartSap = '{sap}'
SET @EndSap = '{/sap}'

-- First find start-loop tag in template
SET @StartPos = CharIndex(@StartTag, @Template, 0)
SET @CurrentPos = 1
WHILE @CurrentPos > 0 AND @StartPos > 0
BEGIN
	-- Goto the end of start-loop tag string
	SET @StartPos = @StartPos+Len(@StartTag)
	SET @EndPos = CharIndex(@EndTag, @Template, @StartPos)
	SET @Snippet = SubString(@Template, @StartPos, @EndPos-@StartPos)

	SET @TempSnippet = ''
	OPEN CurColumnList
	FETCH NEXT FROM CurColumnList INTO @ColumnName, @DataType, @MaxLength, @IsNull
	SET @SapCount = 1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @RenderedSnippet = @Snippet
		SET @RenderedSnippet = REPLACE(@RenderedSnippet, '$table', @PrintTableName)
		SET @RenderedSnippet = REPLACE(@RenderedSnippet, '$field', @ColumnName)
		SET @RenderedSnippet = REPLACE(@RenderedSnippet, '$length', @MaxLength)

		-- Set .NET data type for respective data type of column
		SELECT @RType = CASE @DataType
			WHEN 'bit' THEN 'Boolean'
			WHEN 'tinyint' THEN 'Int16'
			WHEN 'smallint' THEN 'Int32'
			WHEN 'bigint' THEN 'Int64'
			WHEN 'int' THEN 'Int32'
			WHEN 'varchar' THEN 'String'
			WHEN 'nvarchar' THEN 'String'
			WHEN 'char' THEN 'String'
			WHEN 'text' THEN 'String'
			WHEN 'float' THEN 'Double'
			WHEN 'decimal' THEN 'Double'
			WHEN 'numeric' THEN 'Double'
			WHEN 'money' THEN 'Double'
			WHEN 'smalldatetime' THEN 'DateTime'
			WHEN 'datetime' THEN 'DateTime'
			WHEN 'uniqueidentifier' THEN 'Guid'
			ELSE '?'+@DataType
		END

		IF (UPPER(@DataType) = 'NVARCHAR')
			SET @MaxLength=@MaxLength/2

		IF ((UPPER(@DataType) = 'VARCHAR') OR (UPPER(@DataType) = 'NVARCHAR'))
			SET @RenderedSnippet = REPLACE(@RenderedSnippet, '$sp_type', UPPER(@DataType) + '(' + CAST(@MaxLength AS VARCHAR(10)) + ')')
		ELSE
			SET @RenderedSnippet = REPLACE(@RenderedSnippet, '$sp_type', UPPER(@DataType))


		SET @RenderedSnippet = REPLACE(@RenderedSnippet, '$type', @RType)

		-- Set .NET default value for respective data type of column
		SELECT @RDefault = CASE @DataType
			WHEN 'bigint' THEN '0'
			WHEN 'int' THEN '0'
			WHEN 'tinyint' THEN '0'
			WHEN 'smallint' THEN '0'
			WHEN 'bit' THEN '0'
			WHEN 'varchar' THEN 'String.Empty'
			WHEN 'nvarchar' THEN 'String.Empty'
			WHEN 'char' THEN 'String.Empty'
			WHEN 'text' THEN 'String.Empty'
			WHEN 'float' THEN '0.0'
			WHEN 'decimal' THEN '0.0'
			WHEN 'numeric' THEN '0.0'
			WHEN 'money' THEN '0.0'
			WHEN 'smalldatetime' THEN 'DateTime.MinTime'
			WHEN 'datetime' THEN 'DateTime.MinTime'
			WHEN 'uniqueidentifier' THEN 'Guid.Empty'
			ELSE '?'+@DataType
		END
		SET @RenderedSnippet = REPLACE(@RenderedSnippet, '$default', @RDefault)
		IF (@SapCount < @TotalColumn)
		BEGIN
			SET @RenderedSnippet = REPLACE(@RenderedSnippet, @StartSap, '')
			SET @RenderedSnippet = REPLACE(@RenderedSnippet, @EndSap, '')
		END
		ELSE
		BEGIN
			SET @RenderedSnippet = SubString(@RenderedSnippet, 0, CharIndex(@StartSap, @RenderedSnippet, 0))
		END

		SET @TempSnippet = @TempSnippet + @RenderedSnippet
		FETCH NEXT FROM CurColumnList INTO @ColumnName, @DataType, @MaxLength, @IsNull
		SET @SapCount = @SapCount + 1
	END
	CLOSE CurColumnList
	--print '>' + @TempSnippet

	-- Put back rendered snippet into the template
	SET @Template = REPLACE(@Template, @StartTag+@Snippet+@EndTag, @TempSnippet)

	-- Get the next position for start loop tag in the template
	Set @StartPos = CharIndex(@StartTag, @Template, @EndPos+1)
	SET @CurrentPos = @StartPos
END

-- If printable table name is not specified than use table name instead
IF (@PrintTableName = '')
	SET @PrintTableName = @TableName

-- Replace $table tag with the printable table name
SET @Template = REPLACE(@Template, '$table', @PrintTableName)

-- Ignore first line of template, which can be used as the template description, author, template version, additional comment etc.
-- Simply remove following line if you dont want comment segment in the template
SET @CurrentPos = CharIndex(CHAR(13)+CHAR(10), @Template, 0)
SET @CurrentPos = CharIndex(CHAR(13)+CHAR(10), @Template, @CurrentPos+2) + 2
SET @Template = SubString(@Template, @CurrentPos, Len(@Template))
--/

-- Print generated code in the result pane of SQL Server Management Studio
PRINT @Template

DEALLOCATE CurColumnList
SET NOCOUNT OFF