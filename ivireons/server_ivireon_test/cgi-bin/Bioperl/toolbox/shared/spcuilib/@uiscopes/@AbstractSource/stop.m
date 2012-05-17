function stop(this, varargin)
%STOP     wrapper for Controls stop

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/07 14:24:50 $

% stop is on the controls for now
stop(this.Controls,varargin{:});
end

% [EOF]
