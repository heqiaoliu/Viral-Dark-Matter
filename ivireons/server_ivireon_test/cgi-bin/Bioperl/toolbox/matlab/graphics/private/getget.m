function propValue = getget( h, propName )
%GETGET Call GET on a Handle Graphics object or GET_PARAM on a Simulink object.
%   GETGET(H, PN) GET property PN for Handle Graphics object H.
%   GETGET(H, PN) GET_PARAM property PN for Simulink object H.
%   GETGET(N, PN) GET_PARAM property PN for Simulink object named N.
%   If H is a vector, result is concatenated value from vectorized GET and GET_PARAM.
%
%   See also GET, GET_PARAM.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $

if isempty(h)
  propValue = [];
  return
end

if ischar(h)
  h = get_param(h,'handle');
end

%
% find the indices for the HG objects and
% the indices for the Simulink objects - these
% will be used below to populate the result vector
% for the case when the input is a non-homogenous
% array of handles (e.g., some HG, some Simulink).
% Note that the Simulink part is guarded so that we
% don't call Simulink when it's not necessary.
%
hi = find(ishghandle(h));
if length(hi) ~= length(h)
  si = find(isslhandle(h));
else
  si = [];
end

%Put values into same order as handles
propValue = cell(size(h));

if ~isempty(hi)
  hValue = get(h(hi), propName );
  if ~iscell( hValue )
    hValue = { hValue };
  end
  propValue(hi) = hValue;
end

if ~isempty(si)
  sValue = get_param(h(si), propName );
  if ~iscell( sValue )
    sValue = { sValue };
  end
  propValue(si) = sValue;
end

if length(h) == 1 && ~iscell(h)
  propValue = propValue{1};
end
