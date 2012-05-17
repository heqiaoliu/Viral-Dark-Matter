function thisunrender(this, varargin)
%THISUNRENDER Allow the subclass to take control

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2009/01/05 18:01:21 $

delete(handles2vector(this));

if ~isempty(this.Container) && ishghandle(this.Container)
    delete(this.Container);
end

% [EOF]
