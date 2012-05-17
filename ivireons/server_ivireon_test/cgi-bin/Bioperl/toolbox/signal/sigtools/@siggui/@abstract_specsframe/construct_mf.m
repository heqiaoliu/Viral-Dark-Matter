function lvh = construct_mf(h, varargin)
%CONSTRUCT_MF  Construct a freq frame

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:21:30 $

lvh = siggui.labelsandvalues(varargin{:});
addcomponent(h, lvh);

% [EOF]
