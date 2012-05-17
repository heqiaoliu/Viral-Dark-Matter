function [LP, codistr] = hSparsifyImpl(codistr, fcn, LP)
; %#ok<NOSEM> % Undocumented

%   Implementation of hSparsifyImpl for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/29 08:23:29 $

LP = fcn(LP);

end % End of hSParsifyImpl.
