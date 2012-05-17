function [m, descr] = wk1finfo(filename)
%WK1FINFO Determine if file contains Lotus WK1 worksheet.
%   [A, DESCR] = WK1FINFO('FILENAME')
%
%   A is non-empty if FILENAME contains a readable Lotus worksheet.
%
%   DESCR contains a description of the contents or an error message.
%
%   WK1FINFO will be removed in a future release. 
%
%   See also WK1READ, WK1WRITE, CSVREAD, CSVWRITE.

%   Copyright 1984-2009 The MathWorks, Inc.
%
%   $Revision: 1.6.4.5 $  $Date: 2009/12/31 18:51:30 $

warning('MATLAB:wk1finfo:FunctionToBeRemoved', ...
    'WK1FINFO will be removed in a future release.'); 

%
% include WK1 constants
%
wk1const;

% Validate input args
if nargin==0
    error(nargchk(1, 1, nargin, 'struct'));
end

% Get Filename
if ~ischar(filename)
    error('MATLAB:wk1finfo:FilenameMustBeString', 'Filename must be a string.'); 
end

% do some validation
if isempty(filename)
    error('MATLAB:wk1finfo:FilenameIsEmpty', 'Filename must not be empty.'); 
end

% put extension on
if all(filename~='.') 
    filename = [filename '.wk1']; 
end

% Make sure file exists
if ~isequal(exist(filename, 'file'), 2)
    error('MATLAB:wk1finfo:FileNotFound', 'File not found.')
end

% open the file Lotus uses Little Endian Format ONLY
fid = fopen(filename,'rb', 'l');
if fid == (-1)
    error('MATLAB:wk1finfo:FailedToOpen', 'Could not open file %s.',filename);
end

% Read Lotus WK1 BOF
header = fread(fid, 6,'uchar');
if(header' ~= LOTWK1BOFSTR)
    m = '';
    descr = 'Not a Lotus 123 Worksheet';
    fclose(fid);
    return;
end

m = 'WK1';
descr = 'Lotus 123 Spreadsheet';
