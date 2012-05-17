function rcnames = refcoefficientnames(this)
%REFCOEFFICIENTNAMES   

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:04:20 $

super_rcnames = abslatticerefcoefficientnames(this);

rcnames = {super_rcnames{:},'refladder'};

% [EOF]
