function winwrite(h,filename)
%WINWRITE Write a window file.
%   WINWRITE(Hwin) writes an ASCII-file with window weights.  The window
%   values are extracted from the SIGWIN window object, Hwin. Hwin maybe a
%   single SIGWIN object or a vector of SIGWINs. A dialog box is displayed
%   to fill in a file name. The default file name is 'untitled.wf'. 
% 
%   WINWRITE(Hwin,FILENAME) writes the file to a disk file called
%   FILENAME in the present working directory.
%
%   The extension '.wf' will be added to FILENAME if it doesn't already
%   have an extension.
%
%   See also INFO, SIGWIN.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/12/14 15:14:17 $

error(nargchk(1,2,nargin,'struct'));
if nargin < 2, filename = []; end

if isempty(filename),
    filename = 'untitled.wf';
    dlgStr = 'Export Window to .WF file';
    [filename,pathname] = uiputfile('*.wf', dlgStr, filename);
else
    % File will be created in present directory
    s = pwd;
    pathname = [s filesep];
end

if ~isempty(filename),
    if isempty(findstr(filename,'.')), filename=[filename '.wf']; end
    filename = [pathname filename];
end

if ~any(filename == 0),
    save2txtfile(h,filename);
end


%--------------------------------------------------------------
function save2txtfile(h,file)

% Write the coefficients out to a file.
fid = fopen(file,'w');

% Display header information
fprintf(fid,'%s\n',sptfileheader);

txt = getfiletxt(h);

sz = size(txt);
for j = 1:sz(1), % Rows
    fprintf(fid, '%s\n', num2str(txt(j,:),10));
end
fprintf(fid, '\n');

fclose(fid);

% Launch the MATLAB editor (to display the generated file)
edit(file);


% -------------------------------------------------------------------------
function txt = getfiletxt(Hb)
% txt is a character array

strs = cell(length(Hb)*4, 1);    
for idx = 1:length(Hb)
    strs{idx*4-3} = info(Hb(idx));
    strs{idx*4-2} = sprintf('\n');
    strs{idx*4-1} = dispstr(Hb(idx));
    strs{idx*4}   = sprintf('\n');
end
txt = strvcat(strs{:}); %#ok

% [EOF]
