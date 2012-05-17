function info = qeGetHGChar(this)
% qeGetHGChar  Returns struct for testing
% info.Identifier = type of char
% info.HG = handles to hg objects

%  Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:22 $

info = struct(...
    'Identifier', {'Gain Margin';'Phase Margin'}, ...
    'HGLines', {reshape(this.MagPoints,1,1,length(this.MagPoints)); ...
    reshape(this.PhasePoints,1,1,length(this.PhasePoints))});