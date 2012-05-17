function props2add = propstoaddtospectrum(this)
%PROPSTOADDTOSPECTRUM Return properties to be added to the SPECTRUM object.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/07/22 21:15:55 $

allProps = propstoadd(this);

% Exclude the properties listed in the cell array.
props2add = setdiff(allProps,{'Name','Length'});

% [EOF]
