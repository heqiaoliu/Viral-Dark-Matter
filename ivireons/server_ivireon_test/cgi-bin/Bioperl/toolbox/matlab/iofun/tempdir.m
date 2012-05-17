function tmp_dir = tempdir
%TEMPDIR Get temporary directory.
%   TEMPDIR returns the name of the temporary directory if one exists.  A
%   file separator is appended at the end.
%
%   See also TEMPNAME, FULLFILE.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 5.15.4.3 $  $Date: 2007/12/06 13:30:07 $

persistent temporary;
if isempty(temporary)
    if ispc
        tmp_dir = getenv('TEMP');       % Microsoft's recommended name
    else
        tmp_dir = '';
    end
    
    if ( isempty(tmp_dir) )
        tmp_dir = getenv('TMP');    % What everybody else uses
    end
    
    if (isempty(tmp_dir))
        if ispc
            tmp_dir = pwd; % Use current directory 
        else
            tmp_dir = '/tmp/';
        end  
    end         
 %resolve hard links
    curr_dir = cd(tmp_dir);
    tmp_dir = cd(curr_dir);
    if (tmp_dir(end) ~= filesep)
        tmp_dir = [tmp_dir filesep];
    end
    temporary = tmp_dir;
else
    tmp_dir = temporary;
end
