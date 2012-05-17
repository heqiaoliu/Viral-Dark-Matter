function print(hObj)
%PRINT Print the listbox view.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:47 $

% Set your default file name using the temp directory
tname = [tempdir filesep 'fdacoeffs.txt'];

fid = fopen(tname,'wt'); 
if fid ~= -1                     % Check for bad directory
    coeffStr = getanalysisdata(hObj);
    for indx = 1:length(coeffStr),
        for jndx = 1:size(coeffStr{indx}, 1),
            fprintf(fid,'%s\n',coeffStr{indx}(jndx,:)); 
        end
    end
    fclose(fid);
    edit(tname);    
else
    msgbox('Cannot open file to write coefficients.','File Error')
end

% [EOF]
