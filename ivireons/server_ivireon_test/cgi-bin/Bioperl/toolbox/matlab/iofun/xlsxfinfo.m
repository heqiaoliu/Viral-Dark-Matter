function varargout = xlsxfinfo(varargin)
%XLSXFINFO Determine if file contains Microsoft Excel spreadsheet.
%   [A, DESCR, FORMAT] = XLSXFINFO('FILENAME')
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
%   This function is identical to XLSFINFO.
%
%   See also XLSFINFO, XLSREAD, XLSWRITE, CSVREAD, CSVWRITE.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2.4.1 $  $Date: 2010/06/24 19:34:40 $
%==============================================================================

varargout = cell(1,max(nargout,1));
[varargout{:}] = xlsfinfo(varargin{:});