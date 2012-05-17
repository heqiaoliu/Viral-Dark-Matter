classdef Continuous < param.Parameter
   %Construct a continuous parameter
   %
   %    Continuous parameters are numeric parameters that can take on any
   %    value in a specified interval. The parameter can be scalar- or
   %    matrix-valued. Parameters are typically used to create parametric
   %    models and to estimate or tune the free parameters in such models.
   %
   %    Example:
   %      p = param.Continuous('K',eye(2));
   %      p.Free = [true false; false true];
            
   % Copyright 2009-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.1.2.1 $ $Date: 2010/06/28 14:19:24 $
   
   properties(Dependent)
      %VALUE Parameter value
      %
      %    The Value property specifies a scalar- or matrix- value for the
      %    parameter. The dimension of the Value property is fixed on
      %    construction.
      Value
   end %Implemented superclass abstract properties
   
   properties(Dependent)
      %MINIMUM Lower bound for the parameter value
      %
      %    The Minimum property specifies a lower bound for the parameter. The
      %    dimension of the Minimum property matches the dimension of the Value
      %    property. The default value is -inf.
      %
      %    For matrix-valued parameters you can specify lower bounds on
      %    individual matrix elements, e.g.,
      %      p= param.Continuous('K',eye(2));
      %      p.Minimum([1 4]) = -5;
      %
      %    You can use scalar expansion to set the lower bound for all
      %    matrix elements, e.g.,
      %      p= param.Continuous('K',eye(2));
      %      p.Minimum = -5;
      Minimum;
      
      %MAXIMUM Upper bound for the parameter value
      %
      %    The Maximum property specifies an upper bound for the parameter. The
      %    dimension of the Minimum property matches the dimension of the Value
      %    property. The default value is +inf.
      %
      %    For matrix-valued parameters you can specify upper bounds on
      %    individual matrix elements, e.g.,
      %      p= param.Continuous('K',eye(2));
      %      p.Maximum([1 4]) = 5;
      %
      %    You can use scalar expansion to set the upper bound for all
      %    matrix elements, e.g.,
      %      p= param.Continuous('K',eye(2));
      %      p.Maximum = 5;
      Maximum;
      
      %FREE Flag specifying whether the parameter is free to be tuned or not
      %
      %    The Free property specifies whether the parameter is tunable or
      %    not. Set the Free property to true for tunable parameters and false
      %    for fixed parameters. The dimension of the Free property matches
      %    the dimension of the Value property. The default value is true.
      %
      %    For matrix-valued parameters you can fix individual matrix
      %    elements, e.g.,
      %      p= param.Continuous('K',eye(2));
      %      p.Free([2 3]) = false;
      %
      %    You can use scalar expansion to fix all matrix elements, e.g.,
      %      p= param.Continuous('K',eye(2));
      %      p.Free = false;
      Free;
      
      %SCALE Scaling factor used to normalize the parameter value
      %
      %    The Scale property specifies a normalization value for the
      %    parameter. The dimension of the Scale property matches the dimension
      %    of the Value property. The default value is 1.
      %
      %    For matrix-valued parameters you can specify scaling for individual
      %    matrix elements, e.g.,
      %      p= param.Continuous('K',2*eye(2));
      %      p.Scale([1 4]) = 1;
      %
      %    You can use scalar expansion to set the scaling for all matrix
      %    elements, e.g.,
      %      p= param.Continuous('K',eye(2));
      %      p.Scale = 1;
      Scale;
   end % dependent properties
   
   properties(Hidden = true, GetAccess = protected, SetAccess = protected)
      Minimum_
      Maximum_
      Free_
      Scale_
   end % protected properties
   
   methods (Access = public)
      function this = Continuous(name, value)
         %CONTINUOUS Construct a param.Continuous object.
         %
         %    The param.Continuous constructor supports various input argument
         %    signatures
         %       p = param.Continuous
         %       p = param.Continuous(value)
         %       p = param.Continuous(name, [value])
         %
         %    Use param.Continuous to construct an unnamed scalar parameter
         %    with its Value property set to zero. 
         %
         %    Use param.Continuous(value) to construct an unnamed parameter
         %    with its Value property set to a specific value. 
         %
         %    Use param.Continuous(name) to construct a named scalar parameter
         %    with its Value property set to zero. 
         %
         %    Use param.Continuous(name,value) to construct a named parameter
         %    with its Value property set to a specific value.
         
         % Undocumented constructors:
         %    param.Continuous(id, [value])
                
         ni = nargin;
         if (ni > 0)
            error( nargchk(1, 2, ni, 'struct') )
            
            % Default arguments
            if (ni < 2), value = 0; end
            
            % Parse first input argument.
            if ischar(name)
               ID = paramid.Variable( name);
            elseif isa(name, 'paramid.ID')
               ID = name;
            elseif isnumeric(name) && ni == 1
               ID = [];
               value = name;
            else
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgument', 'NAME/ID')
            end
         else
            % Properties for no-argument constructor.
            ID = [];
            value = 0;
         end
         
         % Call superclass constructor first.
         this = this@param.Parameter(ID);
         
         %Set parameter dimensions, do this before setting actual value to
         %avoid dimension check
         this = setSize(this, size(value));
         %Set value property
         this.Value = value;
      end
      function b = isreal(this)
         %ISREAL True for a real parameter
         %
         % b = isreal(p) returns true if the Value, Minimum, and Maximum
         % properties are all real.
         %
         
         b = isreal(this.getPValue) && isreal(this.Minimum_) && isreal(this.Maximum_);
      end
   end % public methods
   
   methods(Hidden = true)
      function pv = getPVec(this, varargin)
         % GETPVEC Gets the variable values.
         %
         %   PV = GETPVEC(OBJ) returns the vector of current variable values.
         %   All variables are included, both free and fixed.
         %
         %   PV = GETPVEC(OBJ,'free') returns the vector of free variable values.
         %
         %   See also SETPVEC.
         [pv,pf] = vec(this);
         if nargin > 1
            % Using the 'free' flag.
            pv = pv(pf);
         end
      end
      
      function this = setPVec(this, pv, varargin)
         % SETPVE Sets the variable values.
         %
         %   OBJ = SETPVEC(OBJ,PV) sets the variable values to the values
         %   specified in the vector PV.  The length of PV should be
         %   equal to the total number of elements in OBJ.
         %
         %   OBJ = SETPVEC(OBJ,PV,'free') sets the values of the free
         %   variables only.  The remaining variables are held at their
         %   current value.
         %
         %   See also GETPVEC.
         if ~isvector(pv)
            ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'PV', 'setPVec')
         end
         
         [p, pf] = vec(this);
         if nargin > 2
            % Using the 'free' flag.
            try
               p(pf) = pv(:);
            catch E
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'PV', 'setPVec')
            end
         else
            if length(pv) ~= length(p)
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'PV', 'setPVec')
            end
            p = pv;
         end
         
         % Assign values
         ip = 0;
         for j = 1:numel(this)
            spj = this(j).getSize;
            npj = prod(spj);
            this(j).Value(:) = p(ip+1:ip+npj); % Reshaped in set.Value
            ip = ip + npj;
         end
      end
      function pNew = catParameter(dim,this,p,name)
         % CATPARAMETER creates a new parameter by concatenating two parameter objects
         %
         % Pnew = catParameter(dim,p1,p2,dim,[name])
         %
         % Concatenate the properties of this object with p along the
         % dimension specified.
         %
         % Inputs:
         %   dim   - dimension along which to concatenate, dim=1 performs 
         %           vertical concatenation, dim=2 performs horizontal 
         %           concatenation, etc.
         %   p1,p2 - the param.Continuous objects to concatenate
         %   name  - an optional string argument with the name of the new
         %           parameter, if omitted the name of this object is reused.
         %
         
         %Check for correct number of arguments
         error(nargchk(3,4,nargin,'struct'))
         
         %Process inputs
         if ~(isnumeric(dim) && isscalar(dim) && isfinite(dim))
            ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'dim', 'catParameter')
         end
         if ~isa(this,'param.Continuous')
            ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'p1', 'catParameter')
         end
         if ~isa(p,'param.Continuous')
            ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'p2', 'catParameter')
         end
         if nargin < 4,
            noID = isempty(this.getID);
            name = this.Name;
         else
            if ~ischar(name)
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'name', 'catParameter')
            end
            noID = isempty(name);
         end
         
         %Concatenate value property and create new parameter object
         try
            newValue = cat(dim,this.Value,p.Value);
         catch E
            throw(E)
         end
         
         if noID
            pNew = param.Continuous(newValue);
         else
            pNew = param.Continuous(name,newValue);
         end
         
         %Concatenate ancillary properties
         pNew = catAncillaryProps(this,p,dim,pNew);
      end
      function pNew = subsrefParameter(this,idx,name)
         % SUBSREFPARAMETER create a new parameter by sub-indexing into a parameter
         %
         % pNew = subsrefParameter(p,idx,[name])
         % pNew = subsrefParameter(p,{idx1,....,idxN},[name])
         %
         % Create a new parameter object from the elements of this parameter
         % object. Element values to use for the new parameter are specified by 
         % the index argument, see subsref for more information on indexing. 
         %
         % Inputs:
         %   idx  - a logical array, an array of ordinal indices, or a cell 
         %          array of coordinate indices. Wildcards, ':', and index
         %          ranges, '5:11', are supported.
         %   name - an optional string argument with the name of the new
         %          parameter, if omitted the name of this object is reused.
         %
         % See also subsref, param.Continuous.subsasgnParameter
         %
         
         %Check for correct number of arguments
         error(nargchk(2,3,nargin,'struct'))
         
         %Process inputs
         if ~iscell(idx), idx = {idx}; end
         if nargin < 3,
            noID = isempty(this.getID);
            name = this.Name;
         else
            if ~ischar(name)
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'name', 'subsrefParameter')
            end
            noID = isempty(name);
         end
            
         %Construct a new parameter object from the elements of this object
         try
            NewValue = this.Value(idx{:});
         catch E
            throw(E)
         end
         if noID
            pNew = param.Continuous(NewValue);
         else
            pNew = param.Continuous(name,NewValue);
         end
         
         %Copy ancillary properties
         pNew = subsrefAncillaryProps(this,pNew,idx);
      end
      function this = subsasgnParameter(this,idx,p)
         % SUBSASGNPARAMETER set the elements of a parameter object from another parameter
         %
         % p = subsasgnParameter(p,idx,p1);
         % p = subsasgnParameter(p,{idx1,...,idxN},p1);
         %
         % Set the elements of this parameter object using the properties 
         % of the passed parameter object. Elements to set are specified by the
         % index argument. The size of the passed parameter object must match 
         % the size implied by the passed index.
         %
         % Inputs:
         %   idx  - a logical array, an array of ordinal indices, or a cell 
         %          array of coordinate indices. Wildcards, ':', and index
         %          ranges, '5:11', are supported.
         %   p1   - a param.Continuous object from which element values
         %          are copied
         %
         % See also subsasgn, param.Continuous.subsrefParameter
         %
         
         %Check for correct number of arguments
         error(nargchk(3,3,nargin,'struct'))
         
         %Process inputs
         if ~isa(p,'param.Continuous')
            ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'p', 'subsasgnParameter')
         end
         if ~iscell(idx), idx = {idx};  end
         
         %Assign the value property
         try
            v = this.Value(idx{:});
            v(:) = p.Value(:);
            this.Value(idx{:}) = v;
         catch E
            throw(E)
         end
         
         %Copy ancillary properties
         this = subsasgnAncillaryProps(this,p,idx);
      end
   end % hidden methods
   
   methods
      %Get/Set methods for implemented abstract dependent Value property
      function this = set.Value(this, value)
         try
            this = setPValue(this, this.formatValueMinMax(value,'Value'));
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.Value(this)
         val = getPValue(this);
      end
      %Get/Set methods for dependent Minimum property
      function this = set.Minimum(this, value)
         try
            this.Minimum_ = this.formatValueMinMax(value,'Minimum',-inf);
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.Minimum(this)
         if isempty(this.Minimum_)
            %Property has not been initialized, return default
            val = -inf(getSize(this));
         else
            val = this.Minimum_;
         end
      end
      %Get/set methods for dependent Maximum property
      function this = set.Maximum(this, value)
         try
            this.Maximum_ = this.formatValueMinMax(value,'Maximum',inf);
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.Maximum(this)
         if isempty(this.Maximum_)
            %Property has not been initialized, return default
            val = inf(getSize(this));
         else
            val = this.Maximum_;
         end
      end
      %Get/set methods for dependent Free property
      function this = set.Free(this, value)
         try
            this.Free_ = this.formatLogicalValue(value,'Free',true);
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.Free(this)
         if isempty(this.Free_)
            %Property has not been initialized, return default
            val = true(getSize(this));
         else
            val = this.Free_;
         end
      end
      %Get/set methods for dependent Scale property
      function this = set.Scale(this, value)
         try
            this.Scale_ = this.formatScale(value,'Scale',1);
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.Scale(this)
         if isempty(this.Scale_)
            %Property has not been initialized, return default
            val = ones(getSize(this));
         else
            val = this.Scale_;
         end
      end
   end % property methods
   
   methods (Hidden = true, Access = protected)
      function [value, free] = vec(this)
         % Vectorizes variable data
         value = zeros(0,1);
         free  = true(0,1);
         for ct = 1:numel(this)
            value = [value; this(ct).Value(:)]; %#ok<AGROW>
            free  = [free;  this(ct).Free(:)];  %#ok<AGROW>
         end
      end
      function value = formatValueMinMax(this, value, prop, default)
         % Convenience method to move numerical property checks out of set methods.
         %
         % Returns [] if the new property value is the same as the default
         % property value. This is for performance and to ensure correct
         % isequal results when comparing against a default object.
         value = this.checkNumeric(value,prop);
         value = this.formatValueToSize(value,prop);
         if (nargin>=4) && isequal(value, default(ones(this.getSize)))
            value = [];
         end
      end
      
      function value = formatScale(this, value, prop, default)
         % Convenience method to move numerical property checks out of set methods.
         %
         % Returns [] if the new property value is the same as the default
         % property value. This is for performance and to ensure correct
         % isequal results when comparing against a default object.
         value = this.checkReal(value,prop);
         value = this.formatValueToSize(value,prop);
         if (nargin>=4) && isequal(value, default(ones(this.getSize)))
            value = [];
         end
      end
      
      function bool = isDefaultValue(this, prop)
         % Method to determine whether a property value has been modified
         % from it's default value. Returns true if the property is
         % unmodified false otherwise.
         %
         % bool = isDefaultValue(this, prop)
         %
         % Inputs:
         %   prop - one of {'Minimum','Maximum','Free','Scale'}
         %
         
         allProp = {'Minimum','Maximum','Free','Scale'};
         if any(strcmp(allProp,prop))
            %Default value indicated by empty private property
            bool = isempty(this.(strcat(prop,'_')));
         else
            try 
               %Call parent class method
               bool = isDefaultValue@param.Parameter(this,prop);
            catch E
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', prop, 'isDefaultValue')
            end
         end
      end
      
      function pNew = catAncillaryProps(this,p,dim,pNew)
         % Convenience method to copy concatenated property values to a
         % parameter object. Called by catParameter method. 
         %
         % This method is separated from catParameter so that subclasses
         % can call it in overloaded catParameter methods.
         
         %Parent class does not support concatenation but there is an Info
         %prop on the parent class that we need to cat, do that directly here
         if ~(isDefaultValue(this,'Info') && isDefaultValue(p,'Info'))
            pNew.Info = cat(dim,this.Info,p.Info);
         end
      
         %Concatenate rest of the ancillary properties. 
         %
         %For performance reasons call this.Minimum_ directly instead of 
         %using isDefaultValue. Use p.isDefaultValue as need access to
         %private property.
         if ~(isempty(this.Minimum_) && isDefaultValue(p,'Minimum'))
            pNew.Minimum = cat(dim,this.Minimum,p.Minimum);
         end
         if ~(isempty(this.Maximum_) && isDefaultValue(p,'Maximum'))
            pNew.Maximum = cat(dim,this.Maximum,p.Maximum);
         end
         if ~(isempty(this.Free_) && isDefaultValue(p,'Free'))
            pNew.Free = cat(dim,this.Free,p.Free);
         end
         if ~(isempty(this.Scale_) && isDefaultValue(p,'Scale'))
            pNew.Scale = cat(dim,this.Scale,p.Scale);
         end
      end
      
      function pNew = subsrefAncillaryProps(this,pNew,idx)
         % Convenience method to copy indexed property values to a new
         % parameter object. Called by subsrefParameter. 
         %
         % This method is separated from subsrefParameter so that subclasses
         % can call it in overloaded subsrefParameter methods.
         
         %Parent class does not support subsref but there is an Info
         %prop on the parent class that we need to subsref, do that directly here
         if ~isDefaultValue(this,'Info')
            pNew.Info = this.Info(idx{:});
         end
         
         %If they are not default copy ancillary properties
         if ~isempty(this.Minimum_)
            pNew.Minimum = this.Minimum(idx{:});
         end
         if ~isempty(this.Maximum_)
            pNew.Maximum = this.Maximum(idx{:});
         end
         if ~isempty(this.Free_)
            pNew.Free = this.Free(idx{:});
         end
         if ~isempty(this.Scale_)
            pNew.Scale = this.Scale(idx{:});
         end
      end
      
      function this = subsasgnAncillaryProps(this,p,idx)
         % Convenience method to assign indexed elements of this object from
         % a passed parameter object. Called by subsasgnParameter
         %
         % This method is separated from subsasgnParameter so that subclasses
         % can call it in overloaded subsasgnParameter methods.
         
         %Parent class does not support subsasgn but there is an Info
         %prop on the parent class that we need to subsasgn, do that directly here
         if ~isDefaultValue(p,'Info')
            v = this.Info(idx{:});
            v(:) = p.Info(:);
            this.Info(idx{:}) = v;
         end
         
         %Assign rest of the ancillary properties. 
         if ~isDefaultValue(p,'Minimum')
            v = this.Minimum(idx{:});
            v(:) = p.Minimum(:);
            this.Minimum(idx{:}) = v;
         end
         if ~isDefaultValue(p,'Maximum')
            v = this.Maximum(idx{:});
            v(:) = p.Maximum(:);
            this.Maximum(idx{:}) = v;
         end
         if ~isDefaultValue(p,'Free')
            v = this.Free(idx{:});
            v(:) = p.Free(:);
            this.Free(idx{:}) = v;
         end
         if ~isDefaultValue(p,'Scale')
            v = this.Scale(idx{:});
            v(:) = p.Scale(:);
            this.Scale(idx{:}) = v;
         end
      end
   end % protected methods
   
   methods (Hidden = true, Sealed, Access = protected)
      
      function value = formatLogicalValue(this, value, prop, default)
         % Convenience method to move logical property checks out of set methods.
         %
         % Returns [] if the new property value is the same as the default
         % property value. This is for performance and to ensure correct
         % isequal results when comparing against a default object.
         try
            value = logical(value);
         catch E
            ctrlMsgUtils.error('Controllib:modelpack:LogicalArrayProperty', prop);
         end
         value = this.formatValueToSize(value,prop);
         if isequal(value, default(ones(this.getSize)))
            value = [];
         end
      end
      
      function value = checkReal(this, value, prop)  %#ok<MANU>
         if ~isnumeric(value) || ~isreal(value)
            ctrlMsgUtils.error('Controllib:modelpack:RealDoubleArrayProperty', prop);
         end
         try
            value = double(value);
         catch E
            ctrlMsgUtils.error('Controllib:modelpack:RealDoubleArrayProperty', prop);
         end
      end
      
      function value = checkNumeric(this, value, prop)  %#ok<MANU>
         if ~isnumeric(value)
            ctrlMsgUtils.error('Controllib:modelpack:DoubleArrayProperty', prop);
         end
         try
            value = double(value);
         catch E
            ctrlMsgUtils.error('Controllib:modelpack:DoubleArrayProperty', prop);
         end
      end
   end % sealed protected methods
   
end % classdef
