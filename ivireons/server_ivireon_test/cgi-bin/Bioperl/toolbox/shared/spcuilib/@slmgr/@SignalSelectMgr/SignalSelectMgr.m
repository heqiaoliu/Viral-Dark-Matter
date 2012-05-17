function this = SignalSelectMgr(varargin)
%SIGNALSELECTMGR Construct a SIGNALSELECTMGR object

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:10 $

this = slmgr.SignalSelectMgr;

this.init(varargin{:});

% [EOF]
