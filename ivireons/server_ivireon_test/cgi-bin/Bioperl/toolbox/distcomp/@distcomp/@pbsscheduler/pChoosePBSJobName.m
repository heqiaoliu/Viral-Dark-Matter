function str = pChoosePBSJobName( ~, str )
; %#ok Undocumented

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/03/22 03:41:55 $

% PBS has a 15-character restriction on the name of a job. Pass in the name
% that you'd like, and this function will truncate it if necessary.

PBS_MAX_JOB_NAME_LENGTH = 15;

if length( str ) > PBS_MAX_JOB_NAME_LENGTH
    str = str( 1:PBS_MAX_JOB_NAME_LENGTH );
end

end
