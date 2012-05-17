function X = hGatherImpl(codistr, LP, destLab)
; %#ok<NOSEM> % Undocumented
% Implementation of hGatherImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:55:33 $

if destLab == 0
    % Gather into a replicated result.
    X = gcat(LP, codistr.Dimension);
else
    % Gather to a single lab.
    X = gcat(LP, codistr.Dimension, destLab);
end
