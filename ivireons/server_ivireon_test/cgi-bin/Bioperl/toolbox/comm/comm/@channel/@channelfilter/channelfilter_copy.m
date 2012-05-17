function h2 = channelfilter_copy(h);
%COPY  Make a copy of a channelfilter object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:21 $

% Copy channelfilter object.
h2 = copy(h);

% Copy buffer and sigresponse objects.
h2.TapGains = copy(h.TapGains);
h2.TapGainsHistory = copy(h.TapGainsHistory);
h2.SmoothIRHistory = copy(h.SmoothIRHistory);
%h2.FreqResponse = copy(h.FreqResponse);  % Not implemented yet.
