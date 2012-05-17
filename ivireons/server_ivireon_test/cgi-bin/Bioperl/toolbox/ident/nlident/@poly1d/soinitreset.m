function nlobj = soinitreset(nlobj)
%SOINITRESET resets initialization of POLY1D object
%
%  nlobj = soinitreset(nlobj)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/10/02 18:55:05 $

% Author(s): Qinghua Zhang

if ~isscalar(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soinitreset')
end

nlobj.prvCoefficients = [];
% This sets nlobj.prvCoefficients to empty while keeping nlobj.Degree
% unchanged.

% FILE END