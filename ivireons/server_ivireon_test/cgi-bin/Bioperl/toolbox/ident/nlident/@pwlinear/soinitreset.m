function nlobj = soinitreset(nlobj)
%SOINITRESET resets initialization of PWLINEAR object
%
%  nlobj = soinitreset(nlobj)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:55:14 $

% Author(s): Qinghua Zhang

if ~isscalar(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soinitreset')
end

nlobj.NumberOfUnits = nlobj.NumberOfUnits;
% This sets nlobj.BreakPoints to empty while keeping nlobj.NumberOfUnits
% unchanged.

% FILE END