function identsinkwrite(name,Ts,in,out,Tstart,isu,isy)
% IDENTSINKWRITE Utility used by the ident sink block to write an iddata
%                object to the workspace

% John Glass 4/2003, Rajiv Singh 11/12/2006

% Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.2.4.3 $  $Date: 2010/03/26 17:24:17 $

%[isu isy]

if isu==0
    in = [];
end

if isy==0
    out = [];
end

z = iddata(out,in,Ts,'TStart',Tstart);
assignin('caller',name,z); % Follow "To Workspace" behavior; write to caller workspace
