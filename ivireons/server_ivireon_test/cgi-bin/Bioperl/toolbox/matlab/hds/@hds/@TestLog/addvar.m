function [v,idx] = addvar(this,varid)
%ADDVAR  Adds variable to TestLog data set.
%
%   V = T.ADDVAR(VARNAME) or V = T.ADDVAR(VARHANDLE)

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:14 $
v = hds.variable(varid);
Vars = this.Cache_.Variables;

% Create variable if non existent
if all(v~=Vars)
   % Update cache
   this.Cache_.Variables = [Vars ; v];
   % Create associated value array
   ValueArray = hds.VirtualArray;
   ValueArray.GridFirst = false;  % sample size always first (grid is 1x1)
   ValueArray.Variable = v;
   this.Data_ = [this.Data_ ; ValueArray];
   idx = length(this.Data_);
   % Add instance property named after variable (user convenience)
   % Add instance property named after variable (user convenience)
   p = schema.prop(this,v.Name,'MATLAB array');
   p.GetFunction = @(this,Value) localGetValue(this,Value);
   p.SetFunction = @(this,Value) localSetValue(this,Value);
end

   % Access functions (nested)
   function A = localGetValue(this,A)
      ValueArray = getContainer(this,v);  % robust to change in container
      A = getArray(ValueArray);
      GridSize = getGridSize(this);
      if ~isempty(A) && GridSize(1)>0 && any(GridSize(2:end)>1)
         GridDim = locateGridVar(this,v);
         if ~isempty(GridDim)
            % Replicate to grid size
            % RE: Grid variables have SampleSize=[1 1]
            A = this.utGridFill(A,GridSize,GridDim);
         end
      end
   end

   function A = localSetValue(this,A)
      ValueArray = getContainer(this,v);  % robust to change in container
      try
         ValueArray.setArray(NewValue);
         ValueArray.SampleSize = hdsGetSize(NewValue);
      catch
         warning('Value of variable %s could not be written.',v.Name)
      end      
      A = [];
   end

end

