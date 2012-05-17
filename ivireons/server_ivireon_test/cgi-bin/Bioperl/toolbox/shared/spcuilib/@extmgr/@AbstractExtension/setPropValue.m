function setPropValue(this, varargin)
%SETPROPVALUE Set the PropValue.
%   setPropValue(H, PROP1, VALUE1) Set the property specified by PROP1 to
%   value specified by VALUE1.  Multiple P/V pairs can be specified.
%   propertyChanged will only fire for the last pair.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/09 21:28:53 $

% Disable the listener so that it doesn't fire for every single property.
this.PropertyListener.Enabled = 'off';

% If we were passed a trailing input, it is the 'noResponse' flag.
noResponse = false;
if rem(nargin, 2) == 0
    noResponse = varargin{end};
    varargin(end) = [];
end

% Loop over and set all of the properties except the last one.
for indx = 1:2:length(varargin)-2
    this.findProp(varargin{indx}).Value = varargin{indx+1};
end

% If we want a response, turn the listener back on so that setting the last
% property will fire it.
if ~noResponse
    this.PropertyListener.Enabled = 'on';
end

% Set the last property.
this.findProp(varargin{end-1}).Value = varargin{end};

% If we do not want a response, turn the listener back on here so that we
% return the object back to its normal state.
if noResponse
    this.PropertyListener.Enabled = 'on';
end

% [EOF]
