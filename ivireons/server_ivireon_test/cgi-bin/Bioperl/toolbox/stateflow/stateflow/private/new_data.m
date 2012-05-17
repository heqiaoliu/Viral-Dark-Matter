function id = new_data(parentId, scope,name)
%NEW_DATA( parentId, scope )

%   Jay R. Torgerson
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.15.2.5 $  $Date: 2008/12/01 08:06:46 $

ds = sf('DataOf', parentId);

if(nargin<3)
   name = unique_name_for_list(ds, 'data');
end
if(nargin<2)
   %%% Data created for functions must be TEMPORARY by default
   %%% For other parents, use LOCAL_DATA
   if(~isempty(sf('find',parentId,'state.type','FUNC_STATE')))
      scope = 'TEMPORARY_DATA';
   elseif is_eml_chart(parentId)
      scope = 'INPUT_DATA';
   else
      scope = 'LOCAL_DATA';
   end
end
id = sf('new','data','.linkNode.parent', parentId, '.name', name, '.scope', scope);
