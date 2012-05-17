function s = getContents(this,Vars)
%GETCONTENTS  Returns list of variable and link values.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:16 $
if nargin==1
   VarNames = getFields(this);
else
   VarNames = get(Vars,{'Name'});
end
% One-shot read
try
   w = warning('off','MATLAB:load:variableNotFound');
   s = load(this.Storage.FileName,VarNames{:});
   warning(w)
   % Be robust to missing variables in file
   if ~isequal(fieldnames(s),VarNames)
      for ct=1:length(VarNames)
         if ~isfield(s,VarNames{ct}),
            s.(VarNames{ct}) = [];
         end
      end
   end 
catch
   s = cell2struct(cell(size(VarNames)),VarNames,1);
end