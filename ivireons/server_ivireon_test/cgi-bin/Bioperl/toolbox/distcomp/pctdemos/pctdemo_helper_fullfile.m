function filename = pctdemo_helper_fullfile(networkDir, file)
%PCTDEMO_HELPER_FULLFILE Build full filename from parts.
%   PCTDEMO_HELPER_FULLFILE(networkDir, file) returns 
%   FULLFILE(networkDir.pc, file) on the PC Windows platform, and 
%   FULLFILE(networkDir.unix, file) on other platforms.
%
%   networkDir must be a structure with the field names 'pc' and 'unix',
%   and the field values must be strings.
%   
%   See also FULLFILE
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:22 $
    
    % Verify the input argument
    error(nargchk(2, 2, nargin, 'struct'));
    tc = pTypeChecker();
    if ~(tc.isStructWithFields(networkDir, 'unix', 'pc') ...
         && iscellstr(struct2cell(networkDir)))
        error('distcomp:demo:InvalidArgument', ...
              ['Network directory must be a structure with the field names '...
              'pc and unix and the field values must be strings']);
    end
    if ~ischar(file) || isempty(file)
        error('distcomp:demo:InvalidArgument', ...
              'File must be a non-empty character array');
    end
    
    if ispc
        base = networkDir.pc;
    else
        base = networkDir.unix;
    end
    filename = fullfile(base, file);
end % End of pctdemo_helper_fullfile
