function dat1 = setexp(dat,datnew,name)
% IDDATA/SETEXP
%
%    The function to add or set experiments is achieved by the
%    command MERGE.
%
%   See HELP IDDATA/MERGE

%   Copyright 1986-2006 The MathWorks, Inc.  
%   $Revision: 1.2.4.1 $  $Date: 2006/09/30 00:19:04 $

if ~isempty(name)
    datnew.ExperimentName = name;
end

dat1 = merge(dat,datnew);

