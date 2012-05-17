function info = qeGetHGChar(this)
% qeGetHGChar  Returns struct for testing
% info.Identifier = type of char
% info.HG = handles to hg objects

%  Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:18 $

% make MagPoints and PhasePoints have coordinants corresponding to axes
MagPoints = [reshape(this.MagPoints,1,1,length(this.MagPoints)); ...
     handle(NaN(1,1, length(this.MagPoints)))];

PhasePoints = [handle(NaN(1,1, length(this.PhasePoints))); ...
    reshape(this.PhasePoints,1,1,length(this.PhasePoints))];
    

info = struct(...
    'Identifier', {'Gain Margin';'Phase Margin'}, ...
    'HGLines', {MagPoints; PhasePoints});