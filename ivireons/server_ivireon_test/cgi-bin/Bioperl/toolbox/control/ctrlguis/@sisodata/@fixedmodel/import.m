function import(this,G)
% Imports model data.
% G is a structure with fields Name and Model.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/03/26 17:22:15 $

this.Name = G.Name;
this.Variable = G.Variable;
this.Model = G.Value;

% @ssdata or @frddata representation
if isa(this.Model,'frd')
    D = getPrivateData(this.Model(1,1,:));
else
    D = getPrivateData(ss(this.Model(1,1,:)));
end

this.ModelData = D;


