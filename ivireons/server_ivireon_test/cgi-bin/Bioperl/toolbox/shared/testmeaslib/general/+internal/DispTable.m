classdef DispTable < handle
    %internal.DispTable Create a display table in the command window
    %    Displays a table in the command window that is aesthetically
    %    pleasing and dynamically laid out.  Supports hyperlinked entries and
    %    column headers.  You must add columns before adding rows.  The
    %    table correctly renders under conditions in which hyperlinks are
    %    not appropriate, such as publishing.
    %
    %    This undocumented class may be removed in a future release.
    %
    %    OBJ = internal.DispTable() creates a table OBJ that will display.
    %
    %    Example 1:
    %        myTable = internal.DispTable();
    %        myTable.addColumn('Year','right')
    %        myTable.addColumn('Document')
    %        myTable.addColumn('Author')
    %        myTable.addRow(1215,internal.DispTable.hyperlink('Magna Carta','http://en.wikipedia.org/wiki/Magna_Carta'),'UK Barons')
    %        myTable.addRow(1776,internal.DispTable.hyperlink('Declaration of Independence','http://en.wikipedia.org/wiki/United_States_Declaration_of_Independence'),'Continental Congress')
    %        myTable.addRow(1840,internal.DispTable.hyperlink('Treaty of Waitangi','http://en.wikipedia.org/wiki/Treaty_of_Waitangi'),'British Crown')
    %        myTable
    %
    %     Example 2:
    %        myTable = internal.DispTable(); 
    %        myTable.Indent = 5; % Indent the table 5 spaces
    %        myTable.addColumn('Command')
    %        myTable.addColumn('demo')
    %        myTable.addColumn('documentation')
    %        myTable.addRow('ver',internal.DispTable.matlabLink('show me','ver(''matlab'')'),internal.DispTable.helpLink('ver','ver'))
    %        myTable.addRow('fft',internal.DispTable.matlabLink('show me','plot(fft(rand(10)))'),internal.DispTable.docLink('fft','fft'))
    %        myTable.addRow('ifft',internal.DispTable.matlabLink('show me','ifft(rand(3))'),internal.DispTable.docLink('ifft','ifft'))
    %        myTable
    %
    %    See also internal.DispTable.addColumn,internal.DispTable.addRow
    
    %
    % To Do list for this class:
    % 1. Implement add of multiple rows at once
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.3 $  $Date: 2010/05/10 17:38:21 $
    
    properties(Access=private)
        ColumnHeader = cell(0);
        ColumnCellAlignment = cell(0);
        RowData = cell(0,0);
    end
    
    properties(Access=private,Dependent)
        NumberOfRows
        NumberOfColumns
    end
    
    properties(Access=public)
        %ColumnSeparator This controls the string used between columns
        ColumnSeparator = ' ';

        %HeaderSeparator This controls the character used between the
        %    header and the rows.  If empty, the separator row is not
        %    displayed.
        HeaderSeparator = '-';
        
        % Indent Controls how many spaces the display is indented
        Indent = 0;
        
        % ShowHeader If false, the header rows of the table are not shown
        ShowHeader = true;
    end
    
    methods
        function obj = DispTable()
            error(nargchk(0,0,nargin,'struct'))
        end
        
        function addColumn(obj,columnName,cellAlignment)
        %addColumn Add a column to a table
        %    OBJ.addColumn(COLUMNNAME) adds a column with the name
        %    COLUMNNAME to the table OBJ, with cells left justified. All
        %    columns must be added before adding rows.
        %
        %    OBJ.addColumn(COLUMNNAME,CELLALIGNMENT) adds a column with
        %    cells justified as specified -- 'left','right', or 'center'.
        %    All columns must be added before adding rows.
        %
        %    COLUMNNAME may contain text, scalar numerics, or hyperlinks
        %
        %    See also
        %    internal.DispTable.addRow,internal.DispTable.hyperlink,internal.DispTable.matlabLink, internal.DispTable.helpLink, internal.DispTable.docLink.
            error(nargchk(2,3,nargin,'struct'))
            
            if nargin < 3
                cellAlignment = 'left';
            else
                cellAlignment = lower(cellAlignment);
            end
            
            if obj.NumberOfRows > 0
                MessageID('testmeaslib:DispTable:rowsPreviouslyAdded').error();
            end
            
            if ~internal.DispTable.isHyperlink(columnName) && ~ischar(columnName)
                if isscalar(columnName) && isnumeric(columnName)
                    % If it's a scalar number, make it a string
                    columnName = num2str(columnName);
                else
                    MessageID('testmeaslib:DispTable:columnNameInvalid').error();
                end
            end
            
            if ~ischar(cellAlignment) || isempty(strmatch(cellAlignment,...
                    {'left','center','right'},...
                    'exact'))
                MessageID('testmeaslib:DispTable:columnCellAlignmentInvalid').error();
            end
            
            obj.ColumnHeader{end+1} = columnName;
            obj.ColumnCellAlignment{end+1} = cellAlignment;
        end
        
        function addRow(obj,varargin)
        %addRow Add a row to a table
        %    OBJ.addRow(ROWCONTENTS) adds a row with the contents of the
        %    ROWCONTENTS cell array.  ROWCONTENTS must be a 1xN cell array,
        %    where N equals the number of columns added.  Columns must be
        %    added before any rows are added.
        %
        %    OBJ.addRow(ROWCONTENT1,ROWCONTENT2,...,ROWCONTENTN) adds a row
        %    with the contents defined by each parameters
        %    ROWCONTENT1...ROWCONTENTN, where N equals the number of columns
        %    added.
        %
        %    ROWCONTENT may contain text, scalar numerics, or hyperlinks
        %
        %    See also internal.DispTable.addColumn,internal.DispTable.hyperlink,internal.DispTable.matlabLink, internal.DispTable.helpLink, internal.DispTable.docLink.
            if obj.NumberOfColumns == 0
                MessageID('testmeaslib:DispTable:addColumnsFirst').error();
            end
            
            if nargin == 2
                if iscell(varargin{1})
                    % Single argument: it is a cell array
                    cellsForRow = varargin{1};
                else
                    % Single argument, and it's a single item
                    cellsForRow = varargin;
                end
            elseif nargin > 2
                % Multiple arguments, treat as cell array
                cellsForRow = varargin;
            else
                error('MATLAB:minrhs','Not enough input arguments.');
            end
            
            if ~isvector(cellsForRow)
                MessageID('testmeaslib:DispTable:argumentsMustBeAVector').error();
            end
            
            if length(cellsForRow) ~= obj.NumberOfColumns
                MessageID('testmeaslib:DispTable:argumentsMustMatchColumns').error();
            end
            
            cellsForRow = cellfun(@renderCellToString,cellsForRow,'UniformOutput',false);
            obj.RowData(end+1,:) = cellsForRow;
            
            function value = renderCellToString(value)
                if ischar(value) || internal.DispTable.isHyperlink(value)
                    return
                elseif isscalar(value) && isnumeric(value)
                    value = num2str(value);
                elseif islogical(value)
                    if value
                        value = 'true';
                    else
                        value = 'false';
                    end
                else
                    MessageID('testmeaslib:DispTable:invalidCell').error();
                end
            end
        end
        
        function disp(obj)
        %disp Show the table
        %    OBJ.disp overrides the standard DISP method to render the table
            assert(nargin == 1)
            fprintf(obj.getDisplayText())
        end
        
        function result = getDisplayText(obj,showHotLinks)
        % getDisplayText returns the rendered text of the table
        % [RESULT] = getDisplayText() returns RESULT, a string with all
        % necessary HTML and formatting characters, suitable for use with
        % FPRINTF.
        %
        % [RESULT] = getDisplayText(SHOWHOTLINKS) controls whether HTML
        % references are inserted.  Setting SHOWHOTLINKS true forces
        % generation of HTML tags.  Default is based on current value of
        % feature('hotlinks').
        %
        % See also FPRINTF
        
            % Check parameters
            error(nargchk(1,2,nargin,'struct'))
            
            if nargin < 2
                showHotLinks = feature('hotlinks');
            end
            
            %G574865 -- handle no columns gracefully
            if obj.NumberOfColumns == 0
                result = '';
                return
            end
            
            % Calculate the column widths
            columnWidth = obj.calcColumnWidths();
            
            result = '';
            if obj.ShowHeader
                % Display the header
                firstline = blanks(obj.Indent);
                secondline = blanks(obj.Indent);
                for iColumn = 1:obj.NumberOfColumns
                    firstline = [firstline...
                        internal.DispTable.renderEntry(obj.ColumnHeader{iColumn},showHotLinks,columnWidth(iColumn),'center')...
                        obj.ColumnSeparator]; %#ok<AGROW>
                    secondline = [secondline...
                        repmat(obj.HeaderSeparator,1,columnWidth(iColumn))...
                        obj.ColumnSeparator]; %#ok<AGROW>
                end
                %Trim the extra ColumnSeparator
                if ~isempty(obj.ColumnSeparator)
                    firstline(end-(length(obj.ColumnSeparator)-1):end) = [];
                    secondline(end-(length(obj.ColumnSeparator)-1):end) = [];
                end
                
                if ~isempty(obj.HeaderSeparator)
                    result = [result sprintf('%s\n%s\n',firstline,secondline)];
                else
                    % Don't put in the header separator if it is empty.
                    result = [result sprintf('%s\n',firstline)];
                end
            end
            
            % Display the cells
            for iRow = 1:obj.NumberOfRows
                rowLine = blanks(obj.Indent);
                for iColumn = 1:obj.NumberOfColumns
                    rowLine = sprintf('%s%s%s',rowLine,...
                        internal.DispTable.renderEntry(obj.RowData{iRow,iColumn},...
                            showHotLinks,...
                            columnWidth(iColumn),...
                            obj.ColumnCellAlignment{iColumn}),...
                        obj.ColumnSeparator);
                end
                %Trim the extra ColumnSeparator
                if ~isempty(obj.ColumnSeparator)
                    rowLine(end-(length(obj.ColumnSeparator)-1):end) = [];
                end
                % G637486: Remove unneeded spaces at the end of the table.
                rowLine = deblank(rowLine);
                result = [result sprintf('%s\n',rowLine)]; %#ok<AGROW>
            end
        end
        
    end
    
    methods(Static)
        function [result] = hyperlink(text,href)
        %internal.DispTable.hyperlink Create hyperlink in a table.
        %
        %    internal.DispTable.hyperlink(TEXT,HREF) creates a hyperlink for
        %    use with addColumn or addRow where TEXT will appear as a link
        %    in the command window, and HREF is the URI for the operation.
        %
        %    Example:
        %        internal.DispTable.hyperlink('MathWorks web site','http://www.mathworks.com')
        %
        %    See also: internal.DispTable.matlabLink, internal.DispTable.helpLink, internal.DispTable.docLink.
            error(nargchk(2,2,nargin))
            
            if ~ischar(text)
                if isscalar(text) && isnumeric(text)
                    % If text is a scalar number, make it a string
                    text = num2str(text);
                else
                    MessageID('testmeaslib:DispTable:hyperlinkTextInvalid').error();
                end
            end
            if ~ischar(href)
                MessageID('testmeaslib:DispTable:hyperlinkHrefInvalid').error();
            end
            
            result.text = text;
            result.href = href;
        end
        
        function [result] = matlabLink(text,command)
        %internal.DispTable.matlabLink Create hyperlink that executes.
        %
        %    internal.DispTable.matlabLink(TEXT,COMMAND) creates a
        %    hyperlink for use with addColumn or addRow where TEXT will
        %    appear as a link in the command window, and COMMAND is the
        %    MATLAB command to execute.
        %
        %    Example:
        %        internal.DispTable.matlabLink('plot random data','plot(rand(10)')
        %
        %    See also: internal.DispTable.hyperlink, internal.DispTable.helpLink, internal.DispTable.docLink.
            error(nargchk(2,2,nargin))
            result = internal.DispTable.hyperlink(text,sprintf('matlab:%s',command));
        end
        
        function [result] = helpLink(text,helpTopic)
        %internal.DispTable.helpLink Create hyperlink that provides command line help.
        %
        %    internal.DispTable.helpLink(TEXT,HELPTOPIC) creates a hyperlink for
        %    use with addColumn or addRow where TEXT will appear as a
        %    link in the command window, and clicking it shows help at the
        %    command line on HELPTOPIC.
        %
        %    Example:
        %        internal.DispTable.helpLink('fft')
        %
        %    See also: internal.DispTable.hyperlink, internal.DispTable.matlabLink, internal.DispTable.docLink.
            error(nargchk(2,2,nargin))
            result = internal.DispTable.hyperlink(text,sprintf('matlab:help(''%s'')',helpTopic));
        end
        
        function [result] = docLink(text,docTopic)
        %internal.DispTable.docLink Create hyperlink that provides opens the help browser.
        %
        %    internal.DispTable.docLink(TEXT,DOCTOPIC) creates a hyperlink for
        %    use with addColumn or addRow where TEXT will appear as a
        %    link in the command window, and clicking it shows the help
        %    browser and selects the topic HELPTOPIC.
        %
        %    Example:
        %        internal.DispTable.docLink('fft')
        %
        %    See also: internal.DispTable.hyperlink, internal.DispTable.matlabLink, internal.DispTable.helpLink.
            error(nargchk(2,2,nargin))
            result = internal.DispTable.hyperlink(text,sprintf('matlab:doc(''%s'')',docTopic));
        end
    end
    
    methods(Access=private)
        function columnWidths = calcColumnWidths(obj)
            % [COLUMNWIDTHS] = DispTable.calcColumnWidths returns a 1xn
            % vector of integers dynamically describing the maximum width of
            % the contents of each column in the table.
            columnWidths = cellfun(@internal.DispTable.getEntryLength,obj.ColumnHeader);
            columnWidths = [columnWidths;cellfun(@internal.DispTable.getEntryLength,obj.RowData)];
            
            %  This syntax of max returns the largest elements along the
            %  first dimension. See the doc for max for details.
            columnWidths = max(columnWidths,[],1);
        end
    end
    
    methods
        function result = get.NumberOfColumns(obj)
            result = length(obj.ColumnHeader);
        end
        function result = get.NumberOfRows(obj)
            result = size(obj.RowData,1);
        end
    end
    
    methods(Access=private,Static)
        function [result] = isHyperlink(input)
            assert(nargin == 1)
            result = false;
            if ~isstruct(input)
                return
            end
            
            if ~all(strcmp(fields(input),{'text';'href'}))
                return
            end
            
            if ~ischar(input.href) || ~ischar(input.text)
                return
            end
            
            result = true;
        end
        
        function [result] = getEntryLength(entry)
            % Test
            assert(nargin == 1)
            
            result = length(internal.DispTable.getEntryText(entry));
        end
        
        function [result] = getEntryText(entry)
            assert(nargin == 1)
            assert(internal.DispTable.isHyperlink(entry) || ischar(entry),...
                'getEntryText requires a string or a hyperlink.')
            
            if internal.DispTable.isHyperlink(entry)
                result = entry.text;
            else
                result = entry;
            end
        end
        
        function [result] = getHref(entry)
            assert(nargin == 1)
            assert(internal.DispTable.isHyperlink(entry),'getHref requires a hyperlink.')
            
            result = entry.href;
        end
        
        function [result] = renderEntry(entry,showHotLinks,minWidth,cellAlignment)
            assert(nargin == 4)
            
            assert(ischar(cellAlignment) &&...
                ~isempty(strmatch(cellAlignment,...
                    {'left','center','right'},'exact')),...
                    'cellAlignment must be ''left'',''right'', or ''center''')
            
            entryLength = internal.DispTable.getEntryLength(entry);
            
            switch cellAlignment
                case 'left'
                    leftMargin = 0;
                    rightMargin = max(minWidth - entryLength,0);
                case 'right'
                    leftMargin = max(minWidth - entryLength,0);
                    rightMargin = 0;
                case 'center'
                    leftMargin = max(floor((minWidth - entryLength)/2),0);
                    rightMargin = max(minWidth - entryLength - leftMargin,0);
            end
            
            
            if ~showHotLinks || ~internal.DispTable.isHyperlink(entry)
                result = [blanks(leftMargin)...
                            internal.DispTable.getEntryText(entry)...
                            blanks(rightMargin)];
            else
                result = sprintf('%s<a href="%s">%s</a>%s',...
                    blanks(leftMargin),...
                    internal.DispTable.getHref(entry),...
                    internal.DispTable.getEntryText(entry),...
                    blanks(rightMargin));
            end
        end
    end
    
end

% LocalWords:  AVector CELLALIGNMENT COLUMNNAME COLUMNWIDTHS HELPTOPIC
% LocalWords:  ROWCONTENT ROWCONTENTN ROWCONTENTS calc xn
