function add_temp_path
%ADD_TEMP_PATH Add temporary NNET directory to path.

%   $Revision: 1.1.8.1 $  $Date: 2010/03/22 04:15:10 $
% Copyright 1992-2010 The MathWorks, Inc.
  
%persistent done
%if isempty(done)
    nntempdir=fullfile(tempdir,'matlab_nnet');
    if ~exist(nntempdir,'dir')
        mkdir(tempdir,'matlab_nnet')
    end
    if isempty(findstr(path,nntempdir))
        path(path,nntempdir);
    end
%    done=1;
%end
