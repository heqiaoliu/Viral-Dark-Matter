function addbuffer(T,str,varargin)

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:14:47 $

%% Add a new M recorder string to the buffer
T.Buffer = [T.Buffer; {str}];
