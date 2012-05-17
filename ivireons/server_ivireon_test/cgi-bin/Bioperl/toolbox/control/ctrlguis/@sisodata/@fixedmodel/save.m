function Data = save(this,Data)
% Saves model data.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/12/22 17:40:13 $
if nargin==1
   Data = struct('Name',this.Name,'Value',this.Model,'Variable',this.Variable);
else
   Data.Name = this.Name;
   Data.Value = this.Model;
   Data.Variable = this.Variable;
end
   
