function this = SignalSelect(varargin)
%SIGNALSELECT Construct a SIGNALSELECT object
%   H = SIGNALSELECT(PATH) Construct a SignalSelect object on 

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:58 $

this = slmgr.SignalSelect;

this.init(varargin{:});

% [EOF]
