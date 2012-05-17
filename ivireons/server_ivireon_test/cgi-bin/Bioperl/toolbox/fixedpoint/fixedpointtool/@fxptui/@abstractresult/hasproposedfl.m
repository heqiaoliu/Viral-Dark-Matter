function b = hasproposedfl(h)
%HASPROPOSEDFL   True if the object has proposed fraction length.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:32 $

b = ~isempty(h.ProposedFL) && ...
    ~strcmp(fxptui.getemptycellchar, h.ProposedFL) && ...
    isempty(h.Comments);

% [EOF]
