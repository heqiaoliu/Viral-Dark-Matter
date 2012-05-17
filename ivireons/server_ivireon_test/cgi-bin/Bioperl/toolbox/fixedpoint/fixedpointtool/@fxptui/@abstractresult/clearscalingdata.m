function clearscalingdata(h)
%CLEARSCALINGDATA clears autoscale related data

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:16:49 $

% h.DesignMin = '';
% h.DesignMax = '';
% h.SpecifiedDT = '';
h.ProposedFL = [];
h.ProposedMin = [];
h.ProposedMax = [];
h.ProposedRange = '';
h.WordLengthSpecified = 0;
h.SignedSpecified = 0;
h.RepresentableMinProposed = 0;
h.RepresentableMaxProposed = 0;
h.ProposedDT = '';
h.DTGroup = '';
h.LocalExtremumSet = [];
h.SharedExtremumSet = [];
h.InitValueMin = [];
h.InitValueMax = [];
h.ModelRequiredMin = [];
h.ModelRequiredMax = [];
h.Accept = 0;
h.Comments = {};
h.Alert = '';
h.actualSrcBlk = {};
h.hasDTConstraints = false;
h.DTConstraints = {};
% [EOF]
