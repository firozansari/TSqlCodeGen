# TSqlCodeGen

TSqlCodeGen is a simple template based SQL script code generator which generates code using table structure. Provide your target table and template to the TSqlCodeGen and it will generate code you for based on your template. The tool is very handy if you are dealing with a table with a large number of columns.

## How To
Open TSqlCodeGen script in the SQL Management Studio, provide your table name and template, press F5 to execute TSqlCodeGen and have your code generated in result Pane. 
Copy generated code from the result pane and paste in your project.

![TSqlCodeGen](./Images/Introduction.PNG)

You can create you own template using following tags as a placeholder for rendering respective entity.

``` sql

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

```

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
