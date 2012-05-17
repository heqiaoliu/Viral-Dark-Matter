function thisloadobj(this, s)
%THISLOADOBJ Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/23 14:04:36 $

if isfield(s,'ResponseType'),
    % The response type was not saved prior to R2010a
    this.ResponseType = s.ResponseType;
end
this.F0    = s.F0;
this.Q     = s.Q;
this.BW    = s.BW;
this.Apass = s.Apass;
this.Astop = s.Astop;

if isfield(s, 'FrequencyConstraints')
    this.FrequencyConstraints = s.FrequencyConstraints;
    this.MagnitudeConstraints = s.MagnitudeConstraints;
end

% [EOF]
