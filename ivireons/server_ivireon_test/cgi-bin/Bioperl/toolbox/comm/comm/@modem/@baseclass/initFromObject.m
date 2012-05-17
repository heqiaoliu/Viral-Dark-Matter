function h = initFromObject(h, varargin)
%INITFROMOBJECT Initialize object H from object 
%   (VARARGIN{1}) to values stored in VARARGIN

% @modem/@baseclass

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:46:50 $

% initialize properties common between the objects
h = initCommonProp(h, varargin{1});

if length(varargin) > 1
    % MODEM.DEMODOBJ(MODOBJ, PROPERTY1, VALUE1, ...) form
    h = initPropValuePairs(h, varargin{2:end});
%else
% MODEM.DEMODOBJ(MODOBJ) form - no need to do anything
end