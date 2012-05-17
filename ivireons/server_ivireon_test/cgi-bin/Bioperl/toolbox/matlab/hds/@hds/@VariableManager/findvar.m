function v = findvar(this,varname)
% Assigns handle to variable or finds handle for given variable.
% A unique handle is associated with each variable.

%   Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/05/02 20:41:10 $

% error stack is reset to avoid droll checks in rtwsim tests. The following
% code would populate the error strcuture afresh and we want to revert back
% to the previous state.
L = lasterror;
if ischar(varname)
   try
      % Return variable handle if there is already a variable of this name
      v = this.VarTable.(varname);
   catch
      % Create new variable and store its handle in hash table
      v = hds.variable(varname,'create');
      this.VarTable.(varname) = v;
   end
else
   % Vectorized version
   nvars = length(varname);
   v = handle(nan(nvars,1));
   vTable = this.VarTable;
   for ct=1:nvars
      vname = varname{ct};
      try
         % Return variable handle if there is already a variable of this name
         v(ct) = vTable.(vname);
      catch
         % Create new variable and store its handle in hash table
         vnew = hds.variable(vname,'create');
         v(ct) = vnew;
         this.VarTable.(vname) = vnew;
      end
   end
end
%reset the error stack
lasterror(L)