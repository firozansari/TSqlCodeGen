# TSqlCodeGen

TSqlCodeGen is a simple template based SQL script code generator which generates code using table structure. Provide your target table and template to the TSqlCodeGen and it will generate code you for based on your template. The tool is very handy if you are dealing with a table with a large number of columns.

## How To
Open TSqlCodeGen script in the SQL Management Studio, provide your table name and template, press F5 to execute TSqlCodeGen and have your code generated in result Pane. 
Copy generated code from the result pane and paste in your project.

![TSqlCodeGen](./Images/Introduction.PNG)

You can create you own TSqlCodeGen template using following tags.

``` sql

$table    : Table name
$field    : Column Name
$type     : .NET Data Type
$sp_type  : SQL Data Type
$default  : .NET Default Value
$length   : Column Max Length

{loop}    : Start Loop Tag
{/loop}   : End Loop Tag

{sap}     : Separator Start Tag
{/sap}    : Separator End Tag

```

## Usage
To understand TSqlCodeGen usage, let's use a basic template which will generate a simple list of columns appended after the table name. 

``` sql
SET @Template = '
** Generate simple list of table columns /v1.0
$table: {loop}$field{sap}{/sap} {/loop}
'
```

Generated Code:
```
Categories: CategoryID CategoryName Description Picture
```

![TSqlCodeGen](./Images/SimpleUsage.PNG)

Now, let's modify the above template so that we can also include a comma after each column names except last one. Note the space after comma in the template and how it translates in the generated code.

``` sql
SET @Template = '
** Generate simple list of table columns saprated by comma /v1.0
$table: {loop}$field{sap}, {/sap} {/loop}
'
```

Generated Code:

```
Categories: CategoryID, CategoryName, Description, Picture
```

![TSqlCodeGen](./Images/UsageWithComma.PNG)

*Note*: the First line of the template is a comment line which will be ignored by TSqlCodeGen. You can use the first line of the template to document your template or provide additional information like template description, author, template version, additional comment, etc.

## License
The MIT License

Copyright (c) 2007-2019 Firoz Ansari. http://firozansari.com

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
