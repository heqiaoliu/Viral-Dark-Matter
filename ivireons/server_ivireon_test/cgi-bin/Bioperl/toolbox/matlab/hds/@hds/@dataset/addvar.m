function v = addvar(this,varid)
%ADDVAR  Adds variable to data set.
%
%   V = D.ADDVAR(VARNAME) or V = D.ADDVAR(VARHANDLE)

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:38 $
v = hds.variable(varid);
Vars = this.Cache_.Variables;
if all(v~=Vars)
   % Update cache
   this.Cache_.Variables = [Vars ; v];
   % Create associated value array
   ValueArray = hds.BasicArray;
   ValueArray.Variable = v;
   this.Data_ = [this.Data_ ; ValueArray];
   % Add instance property named after variable (user convenience)
   p = schema.prop(this,v.Name,'MATLAB array');
   p.CaseSensitive = 'on';
   p.GetFunction = @(this,Value) localGetValue(this,Value);
   p.SetFunction = @(this,Value) localSetValue(this,Value);
   p.AccessFlags.AbortSet = 'off';  % avoids triggering GET for every SET
end

   % Access functions (nested)
   function A = localGetValue(this,A)
      ValueArray = getContainer(this,v);  % robust to change in container
      A = getArray(ValueArray);
      GridSize = getGridSize(this);
      if ~isempty(A) && all(GridSize>0)
         GridDim = locateGridVar(this,v);
         if ~isempty(GridDim) && any(GridSize(2:end)>1)
            % Replicate to grid size
            % RE: Grid variables have SampleSize=[1 1]
            A = this.utGridFill(A,GridSize,GridDim);
         elseif isempty(GridDim) && isscalar(A) && any(GridSize>1)
            % Scalar expansion
            A = hdsReplicateArray(A,GridSize);
         end
      end
   end

   function A = localSetValue(this,A)
      ValueArray = getContainer(this,v);  % robust to change in container
      try
         % Validate array size (also updates grid size if undefined)
         % REVISIT: {} = workaround dispatching woes when NewValue is an object,
         % e.g., lti
         if isscalar(A) && all(getGridSize(this)>0) && isempty(locateGridVar(this,v))
            % Optimized support of scalar expansion for dependent vars
            ValueArray.SampleSize = [1 1];
            ValueArray.setArray(A);
         else
            [NewValue,GridSize,SampleSize] = ...
               utCheckArraySize(this,{A},v,ValueArray.GridFirst);
            % Store data (may fail if array container is read only)
            ValueArray.SampleSize = SampleSize;
            ValueArray.setArray(ValueArray.utReshape(NewValue,GridSize))
         end
      catch
         rethrow(lasterror)
      end
      A = [];
   end

end
