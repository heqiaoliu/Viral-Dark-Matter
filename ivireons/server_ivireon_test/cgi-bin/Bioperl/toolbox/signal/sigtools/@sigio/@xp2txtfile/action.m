function success = action(hCD)
%ACTION Perform the action of exporting to a text-file.

%   Author(s): P. Costa
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2006/06/27 23:40:50 $

[file path] = uiputfile('*.txt', hCD.DialogTitle, hCD.FileName);

if any(file == 0),
    success = false;
else
    file = fullfile(path, file);
    save2textfile(hCD,file);
    success = true;
end



%------------------------------------------------------------------------
function save2textfile(this, file)
%SAVE2TEXTFILE Save filter coefficients to a Text-file
%
% Inputs:
%   file  - String containing the Text-file name.
%   this - Handle to the Export dialog object

fid = fopen(file, 'w');

tbx = this.Toolbox;
if isempty(tbx)
    tbx = 'signal';
end

% Display header information
fprintf(fid,'%s\n',sptfileheader('', tbx));

savevars2textfile(this, fid);

fclose(fid);

% Launch the MATLAB editor (to display the coefficients)
edit(file);

%------------------------------------------------------------------------
function savevars2textfile(this, fid)

labels = get(this, 'VariableLabels');

if isempty(labels), labels = get(this, 'DefaultLabels'); end

% variables & labels are cell arrays of the same length.
variables = formatexportdata(this);

print2file(this, fid, labels, variables);

%-------------------------------------------------------------------
function print2file(this, fid, labels, variables)

for i = 1:length(labels),
    fprintf(fid, '%s:\n', labels{i});
    
    % Only perform this action on a vector.
    if any(size(variables{i}) == 1),
        variables{i} = variables{i}(:);
    end    
    
    sz = size(variables{i});
    for j = 1:sz(1), % Rows
        fprintf(fid, '%s\n', num2str(variables{i}(j,:),10));
    end
    fprintf(fid, '\n');
end

% [EOF]
