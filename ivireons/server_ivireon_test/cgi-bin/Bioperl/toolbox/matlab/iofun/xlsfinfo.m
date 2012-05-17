function [message, description, format] = xlsfinfo(filename)
%XLSFINFO Determine if file contains Microsoft Excel spreadsheet.
%   [A, DESCR, FORMAT] = XLSFINFO('FILENAME')
%
%   A contains the message 'Microsoft Excel Spreadsheet' if FILENAME points to a
%   readable Excel spreadsheet, but is empty otherwise.
%
%   DESCR contains either the names of non-empty worksheets in the workbook
%   FILENAME, when readable, or an error message otherwise.
%
%   FORMAT contains the specific Excel format of the file, if an Excel
%   ActiveX Server can be started.  Otherwise it is empty.  Specific Excel
%   formats include, but are not limited to, 
%           'xlWorkbookNormal', 'xlHtml', 'xlXMLSpreadsheet', 'xlCSV' 
%
%   NOTE: When an Excel ActiveX server cannot be started, functionality is
%           limited in that some Excel files may not be readable.
%
%   See also XLSREAD, XLSWRITE, CSVREAD, CSVWRITE.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.15.4.14.2.1 $  $Date: 2010/06/24 19:34:36 $
%==============================================================================
% Validate filename data type
if nargin < 1
    error('MATLAB:xlsfinfo:Nargin',...
        'Filename must be specified.');
end
if ~ischar(filename)
    error('MATLAB:xlsfinfo:InputClass','Filename must be a string.');
end

% Validate filename is not empty
if isempty(filename)
    error('MATLAB:xlsfinfo:FileName',...
        'Filename must not be empty.');
end

% handle requested Excel workbook filename
filename = validpath(filename,'.xls');

% Don't even attempt to open an excel server if it isn't pc.
if ~ispc
    format = '';
    [message,description] = xlsfinfo_old(filename);
    return
end
%-----------------------------------------------------------------------------
% Attempt to start Excel as ActiveX server process on local host
% try to start ActiveX server
try
    Excel = actxserver('excel.application');
catch exception %#ok
    warning('MATLAB:xlsfinfo:ActiveX',...
            ['Could not start Excel server. ' ...
             'See documentation for resulting limitations.'])
    format = '';
    [message,description] = xlsfinfo_old(filename);
    return
end
%-----------------------------------------------------------------------------
% Open Excel workbook.
Excel.DisplayAlerts = 0; 
workbook = Excel.workbooks.Open(filename, 0, true);
format =  workbook.FileFormat;
if strcmpi(format, 'xlCurrentPlatformText') == 1
    message = '';
    description = 'Unreadable Excel file.';
else
    
    % walk through sheets in workbook and pick out worksheets (not Charts e.g.).
    message = 'Microsoft Excel Spreadsheet';
    indexes = logical([]);
    % Initialise worksheets object.
    workSheets = Excel.sheets;
    description = cell(1,workSheets.Count);
    for i = 1:workSheets.Count
        sheet = get(workSheets,'item',i);
        try
            type = sheet.Type;
        catch e %#ok<NASGU>
            type = '';
        end
        description{i} = sheet.Name;
        indexes(i) = strcmp(type, 'xlWorksheet') || ~isempty(strfind(class(sheet), 'Worksheet'));
    end
    description = description(indexes);
end
try
    workbook.Close(false); % close workbook without saving any changes.
    Excel.Quit;
    delete(Excel); % delete COM server
catch exception %#ok
end

%==============================================================================
function [m, descr] = xlsfinfo_old(filename)

try
    biffvector = biffread(filename);
    m = 'Microsoft Excel Spreadsheet';
    [~,descr] = biffparse(biffvector);
    descr = descr';
catch exception
    m = '';
    descr =  ['Unreadable Excel file: ' exception.message];
end

