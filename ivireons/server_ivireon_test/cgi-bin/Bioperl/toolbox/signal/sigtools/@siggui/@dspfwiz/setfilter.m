function out = setfilter(hObj, out)
%FILTER_LISTENER Listener to the filter property

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:32:09 $

if ~isempty(out) && ~isa(out, 'dfilt.basefilter'),
    error(generatemsgid('InvalidParam'),'You must set a valid filter object in the Filter property.');
end

% Construct a new parameter object with the new filter
parm = dspfwiz.parameter(out);

set(hObj, 'Parameter', parm);

% [EOF]
