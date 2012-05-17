function value = getmetadata(h, run, name)
% GETMETADATA get the VALUE for specified NAME in the specified RUN

%   Author(s): G. Taillefer
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:18:30 $

error(nargchk(3,3,nargin));
if ~h.isSDIEnabled
    % In some situations where the FPT is launched via the FPA, we can come
    % across a situation where the FPT callbacks attempt to operate on a run
    % before the run is initialized. We need to protect against such cases.
    runHash = h.simruns.get(run);
    if isempty(runHash)
        value = [];
    else
        value = runHash.get('metadata').get(name);
    end
end
% [EOF]
