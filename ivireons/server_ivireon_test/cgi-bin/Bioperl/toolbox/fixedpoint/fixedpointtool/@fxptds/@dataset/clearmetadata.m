function clearmetadata(h, run)
%CLEARMETADATA   

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/28 20:19:12 $

error(nargchk(2,2,nargin));
if ~h.isSDIEnabled
    h.simruns.get(run).get('metadata').clear;
end
% [EOF]
