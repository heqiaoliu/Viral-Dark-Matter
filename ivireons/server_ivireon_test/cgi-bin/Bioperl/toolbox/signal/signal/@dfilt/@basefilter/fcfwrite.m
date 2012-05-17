function fcfwrite(h,filename,fmt)
%FCFWRITE Write a filter coefficient file.
%   FCFWRITE(H) writes a filter coefficient ASCII-file. H maybe a single 
%   filter object or a vector of objects. A dialog box is displayed to 
%   fill in a file name. The default file name is 'untitled.fcf'. 
%
%   If the Filter Design Toolbox is installed, FCFWRITE(H) can be
%   used to write filter coefficient files for multirate filter
%   objects, MFILTs, and adaptive filter objects, ADAPTFILTs. 
%
%   FCFWRITE(H,FILENAME) writes the file to a disk file called
%   FILENAME in the present working directory.
%
%   FCFWRITE(...,FMT) writes the coefficients in the format FMT. Valid FMT 
%   values are 'hex' for hexadecimal, 'dec' for decimal, or 'bin' for 
%   binary representation.
%
%   The extension '.fcf' will be added to FILENAME if it doesn't already
%   have an extension.
%
%   See also DFILT/INFO, DFILT.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/12/28 04:35:15 $

error(nargchk(1,3,nargin,'struct'));
if nargin < 3
    fmt = 'dec';
    if nargin < 2
        filename = [];
    end
end


if isempty(filename),
    filename = 'untitled.fcf';
    dlgStr = xlate('Export Filter Coefficients to .FCF file');
    [filename,pathname] = uiputfile('*.fcf', dlgStr, filename);
else
    % File will be created in present directory
    s = pwd;
    pathname = [s filesep];
end

if ~isempty(filename),
    if isempty(findstr(filename,'.')), filename=[filename '.fcf']; end
    filename = [pathname filename];
end

if ~any(filename == 0),
    save2fcffile(h, filename, fmt);
end


%--------------------------------------------------------------
function save2fcffile(h, file, fmt)

% Write the coefficients out to a file.
fid = fopen(file,'w');

% Display header information
fprintf(fid,'%s\n',sptfileheader);

txt = getfiletxt(h, fmt);

switch lower(fmt(1:3))
    case 'hex'
        full_fmt = 'Hexadecimal';
    case 'dec'
        full_fmt = 'Decimal';
    case 'bin'
        full_fmt = 'Binary';
end

fprintf(fid, '\n%% Coefficient Format: %s\n\n', full_fmt);

sz = size(txt);
for j = 1:sz(1), % Rows
    fprintf(fid, '%s\n', num2str(txt(j,:),10));
end
fprintf(fid, '\n');

fclose(fid);

% Launch the MATLAB editor (to display the generated file)
edit(file);

% -------------------------------------------------------------------------
function txt = getfiletxt(Hb, fmt)
% txt is a character array

strs = cell(length(Hb)*4, 1);    
for idx = 1:length(Hb)
    strs{idx*4-3} = info(Hb(idx));
    strs{idx*4-3} = [repmat('% ', size(strs{idx*4-3}, 1), 1) strs{idx*4-3}];
    strs{idx*4-2} = sprintf('\n');
    strs{idx*4-1} = dispstr(Hb(idx), fmt);
    strs{idx*4}   = sprintf('\n');
end
txt = strvcat(strs{:});

% [EOF]
