function postUpdate(this)
%POSTUPDATE 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 16:09:51 $

send(this.Application, 'VisualUpdated');
drawnow expose;

% [EOF]
