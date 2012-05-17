function activate(this)
%ACTIVATE Initialize or reinitialize this source

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/03/31 18:43:52 $

if ~isempty(this.Controls)
    playBack = this.Controls;
    enable(playBack,'on');
    playBack.resetToStart;
end

% [EOF]
