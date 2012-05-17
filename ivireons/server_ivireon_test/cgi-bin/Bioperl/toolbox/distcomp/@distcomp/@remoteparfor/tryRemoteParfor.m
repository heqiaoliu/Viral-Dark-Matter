function OK = tryRemoteParfor()
; %#ok Undocumented

% This is a static method of distcomp.remoteparfor that indicates if it is
% OK to try constructing a distcomp.remoteparfor object. This will stop
% obvious errors being thrown.


%   Copyright 2009 The MathWorks, Inc.

%   $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:58:32 $


session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
OK = ~isempty(session) && session.isPoolManagerSession;
