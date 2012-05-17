%% Display Table Examples
% The |internal.DispTable| class displays a table in the command window that
% is aesthetically pleasing and dynamically laid out.  It supports
% hyperlinked entries and column headers.  You must add columns before
% adding rows.  The table correctly suppresses hyperlinks under conditions
% in which hyperlinks are not appropriate, such as publishing.
% 
% This undocumented class may be removed in a future release.
%
% To see hyperlinks, you can do a |grabcode| on this file to get the code to this demo. 

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/04 16:32:03 $

%% Create a simple table
myTable = internal.DispTable();

%%
% First, add the columns at the top of the table.  The content can be a
% string or scalar numeric.  The second parameter to |addColumn| is
% optional:  It allows you to set the justification of the column -- left,
% right, or center.
myTable.addColumn('Year Authored','right')
myTable.addColumn('Document')
myTable.addColumn('Author')
myTable.addColumn('Northern Hemisphere?')

%%
% Next, add the rows to the table, with an entry for each column
myTable.addRow(1215,'Magna Carta','UK Barons',true)
myTable.addRow(1776,'Declaration of Independence','Continental Congress',true)
myTable.addRow(1840,'Treaty of Waitangi','British Crown',false)

%%
% Calling |disp| of the object will cause it to be displayed
myTable

%%
% Note that the columns expand and contract as needed to accommodate the
% column headers and the contents.

%% Create a table with hyperlinks
% You can define hyperlinks in the headers, and any cell.  Use the
% |hyperlink| static method to specify content when calling |addColumn| or |addRow|.
myTable = internal.DispTable();
myTable.addColumn('Year Authored','right')
myTable.addColumn('Document')
myTable.addColumn('Author')
myTable.addColumn('Northern Hemisphere?')
myTable.addRow(1215,internal.DispTable.hyperlink('Magna Carta','http://en.wikipedia.org/wiki/Magna_Carta'),'UK Barons',true)
myTable.addRow(1776,internal.DispTable.hyperlink('Declaration of Independence','http://en.wikipedia.org/wiki/United_States_Declaration_of_Independence'),'Continental Congress',true)
myTable.addRow(1840,internal.DispTable.hyperlink('Treaty of Waitangi','http://en.wikipedia.org/wiki/Treaty_of_Waitangi'),'British Crown',false)
myTable

%%
% Links to MATLAB documentation and MATLAB command execution can also be created using the |helpLink|
% and |matlabLink| static methods.  Note that these hyperlinks are
% suppressed when using |publish| or when MATLAB is running in console mode.
myTable = internal.DispTable();
myTable.addColumn('Year Authored','right')
myTable.addColumn('Document')
myTable.addColumn('Author')
myTable.addColumn('Northern Hemisphere?')
myTable.addRow(internal.DispTable.matlabLink('1215','datenum(1215,1,1)'),'Magna Carta','UK Barons',true)
myTable.addRow(1776,internal.DispTable.helpLink('Declaration of Independence','function'),'Continental Congress',true)
myTable.addRow(1840,internal.DispTable.docLink('Treaty of Waitangi','function'),'British Crown',false)
myTable

%% Format Modifications
% Many times, it's useful to indent your tables when they are part of a
% larger display operation.
myTable = internal.DispTable();
myTable.Indent = 5;
myTable.addColumn('Year Authored','right')
myTable.addColumn('Document','center')
myTable.addColumn('Author','left')
myTable.addColumn('Northern Hemisphere?')
myTable.addRow(1215,'Magna Carta','UK Barons',true)
myTable.addRow(1776,'Declaration of Independence','Continental Congress',true)
myTable.addRow(1840,'Treaty of Waitangi','British Crown',false)
myTable

%%
% You can control the separator between columns, and the character used at
% between the header and the first row
myTable = internal.DispTable();
myTable.ColumnSeparator = '|';
myTable.HeaderSeparator = '+';
myTable.addColumn('Year Authored','right')
myTable.addColumn('Document')
myTable.addColumn('Author')
myTable.addColumn('Northern Hemisphere?')
myTable.addRow(1215,'Magna Carta','UK Barons',true)
myTable.addRow(1776,'Declaration of Independence','Continental Congress',true)
myTable.addRow(1840,'Treaty of Waitangi','British Crown',false)
myTable

%%
% Setting the |HeaderSeparator| empty removes the separator
myTable = internal.DispTable();
myTable.HeaderSeparator = '';
myTable.addColumn('Year Authored','right')
myTable.addColumn('Document')
myTable.addColumn('Author')
myTable.addColumn('Northern Hemisphere?')
myTable.addRow(1215,'Magna Carta','UK Barons',true)
myTable.addRow(1776,'Declaration of Independence','Continental Congress',true)
myTable.addRow(1840,'Treaty of Waitangi','British Crown',false)
myTable

%%
% You can disable the header entirely, if needed
myTable = internal.DispTable();
myTable.ShowHeader = false;
myTable.addColumn('Year Authored','right')
myTable.addColumn('Document')
myTable.addColumn('Author')
myTable.addColumn('Northern Hemisphere?')
myTable.addRow(1215,'Magna Carta','UK Barons',true)
myTable.addRow(1776,'Declaration of Independence','Continental Congress',true)
myTable.addRow(1840,'Treaty of Waitangi','British Crown',false)
myTable

%%
% The |internal.DispTable| provides a useful, basic display operation to those
% MATLAB developers looking to display information in a tabular form at the
% command line.  Improvements are welcome.
% LocalWords:  Carta Magna Waitangi
