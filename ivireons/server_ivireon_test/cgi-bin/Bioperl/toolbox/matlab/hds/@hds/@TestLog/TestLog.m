function this = TestLog(vars)
%TESTPOINT  Constructs instance of @TestLog class.
%
%   T = HDS.TESTLOG(VARS) constructs a new "Test Log" dataset  
%   with variables VARS.  VARS is either a cell array of variable 
%   names, or a vectors of @variable handles.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:11 $

% Create instance
this = hds.TestLog;
this.Version = 2;
this.Grid_ = struct('Length',1,'Variable',[]);

if nargin>0
   % Convert variables to @variable instances
   if isa(vars,'char')
      V = hds.variable(vars);
   elseif isa(vars,'cell')
      V = handle(zeros(size(vars)));
      for ct=1:length(vars)
         V(ct) = hds.variable(vars{ct});
      end
   else
      V = vars;
   end
   for ct=1:length(V)
      this.addvar(V(ct));
   end
end