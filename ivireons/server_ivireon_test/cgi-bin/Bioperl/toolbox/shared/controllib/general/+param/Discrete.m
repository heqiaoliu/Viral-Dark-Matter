classdef(Hidden = true) Discrete < param.Parameter
   %
   
   %Construct a discrete parameter
   %
   %    Discrete parameters are parameters that can take on any value from a
   %    specified set of values. Discrete parameters are typically used to
   %    parameterize a model and then tuned to optimize the behavior of the
   %    model.
   
   % Copyright 2009-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.1.2.1 $ $Date: 2010/06/28 14:19:26 $
   
   properties(Dependent)
      %VALUE Parameter value
      %
      %    The Value property is a read-write property. The Value property must
      %    be an allowable value specified by the ValueSet property.
      Value
   end % Implemented superclass abstract properties
   
   properties(Dependent)
      %VALUESET Set of allowable parameter values
      %
      %    The ValueSet property specifies the allowable values for a parameter. 
      ValueSet
      
      %FREE Tunable state of the parameter
      %
      %    The Free property specifies whether the parameter is tunable or not.
      %    The dimension of the Free property matches the dimension of the
      %    Value property. The default value is true.
      Free
   end % dependent properties
   
   properties(Hidden = true, GetAccess = protected, SetAccess = protected)
      ValueSet_
      Free_
   end % dependent properties
   
   methods (Access = public)
      function this = Discrete(name, value, valueset)
         %DISCRETE Construct a param.Discrete object
         %
         %    The param.Discrete constructor supports various input argument
         %    signatures
         %      p = param.Discrete
         %      p = param.Discrete(name, [value], [valueset])
         %
         %    Use param.Discrete to construct an unnamed parameter object
         %    with allowable values {0} and its Value property set to 0.
         %
         %    Use param.Discrete(name) to construct a named parameter object
         %    with allowable values {0} and its Value property set to 0.
         %
         %    Use param.Discrete(name,value) to construct a named parameter
         %    object with its Value property set to a specified value and the
         %    allowable values set to the specified value.
         %
         %    Use param.Discrete(name,value,valueset) to construct a named
         %    parameter object with its Value property set to a specified
         %    value and the allowable values set to a specified value.
         
         % Undocumented constructors:
         %   p = param.Discrete(id, [value], [valueset])
         %   p = param.Discrete(value, [valueset]) value is numeric to distinguish from Discrete(name)
         
         ni = nargin;
         if (ni > 0)
            error( nargchk(1, 3, ni, 'struct') )
            
            % Default arguments
            if (ni < 2), value = 0; end
            if (ni < 3), valueset = {value}; end
            
            % Parse first input argument.
            if ischar(name)
               ID = paramid.Variable(name);
            elseif isa(name, 'paramid.ID')
               ID = name;
            elseif ni <= 2
               if ni == 2
                  valueset = value;
               else
                  valueset = {name};
               end
               value = name;
               ID = [];
            else
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgument', 'NAME/ID')
            end
         else
            % Properties for no-argument constructor.
            ID       = [];
            value    = 0;
            valueset = {0};
         end
         
         %Check that the value and valueset arguments  are valid, need to
         %do this check here as can't use property set methods during
         %construction
         if ~iscell(valueset) || isempty(valueset)
            ctrlMsgUtils.error('Controllib:modelpack:errValueSetProperty')
         end
         if ~param.Discrete.isValid(value,valueset)
            ctrlMsgUtils.error('Controllib:modelpack:errNotValidValue')
         end
         
         % Call superclass constructor.
         this = this@param.Parameter(ID);
         
         %Set parameter dimensions, do this before setting actual value to
         %avoid dimension check
         if param.Discrete.isValidElement(value,valueset)
            sz = [1 1];
         else
            %Must be array of elements, would not have passed isValid
            %check above otherwise.
            sz = size(value);
         end
         this = setSize(this, sz);
         % Set valid set of discrete values first and then set value
         this.ValueSet       = valueset;
         this.Value          = value;
      end
   end % public methods
   
   methods
      %Get/Set methods for implemented abstract dependent Value property
      function this = set.Value(this,newvalue)
         try
            if ~param.Discrete.isValid(newvalue,this.ValueSet_)
               ctrlMsgUtils.error('Controllib:modelpack:errNotValidValue')
            end
            %Value cannot change dimension
            oldSize = getSize(this); 
            if param.Discrete.isValidElement(newvalue,this.ValueSet_)
               newSize = [1 1];
            else
               %Must be array of elements, would not have passed isValid
               %check above otherwise.
               newSize = size(newvalue);
            end
            if isequal(oldSize,newSize)
               this = setPValue(this,newvalue);
            else
               ctrlMsgUtils.error('Controllib:modelpack:CannotFormatValueToSize','Value');
            end
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.Value(this)
         val = getPValue(this);
      end
      %Get/Set methods for dependent ValueSet property
      function this = set.ValueSet(this,newvalue)
         try
            if iscell(newvalue) && ~isempty(newvalue)
               this.ValueSet_ = newvalue;
               if ~param.Discrete.isValid(getPValue(this),this.ValueSet_)
                  %The current Value property is not an element of
                  %ValueSet, change it to an element
                  if isequal(getSize(this),[1 1])
                     this = setPValue(this,newvalue{1});
                  else
                     value = cell(getSize(this));
                     [value{:}] = deal(newvalue{1});
                     this = setPValue(this,value);
                  end
               end
            else
               ctrlMsgUtils.error('Controllib:modelpack:errValueSetProperty')
            end
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.ValueSet(this)
         val = this.ValueSet_;
      end
      %Get/Set methods for dependent Free property
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
   end % property methods
   
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
         value = this.checkLogicalValue(value, prop);
         if isequal(value, default(ones(this.getSize)))
            value = [];
         end
      end
      
      function value = checkLogicalValue(this, value, prop)
         % Delegate method for subclass participation in logical value validation.
         value = this.formatValueToSize(value, prop);
      end
   end %sealed protected methods
   
   methods(Hidden = true, Static, Sealed, Access = protected)
      function b = isValidElement(value,valueset)
         %Checks that value is an element of valueset
         b = any(cellfun(@(x) isequal(x,value), valueset));
      end
      
      function b = isValid(value,valueset)
         %Checks that value is either an element from valueset or an array
         %of elements from value set
         
         %Is the value an element of the ValueSet?
         b = param.Discrete.isValidElement(value,valueset);
         
         %Is the value a cell array of elements from the ValueSet?
         if ~b && iscell(value)
            b = true;
            ct = 1;
            while ct <= numel(value) && b
               b = param.Discrete.isValidElement(value{ct},valueset);
               ct = ct + 1;
            end
         end
         
         % Is the value a numeric or logic array of elements from the
         % ValueSet?
         if ~b && (isnumeric(value) || islogical(value)) && numel(value) > 1
            b = true;
            ct = 1;
            while ct <= numel(value) && b
               b = param.Discrete.isValidElement(value(ct),valueset);
               ct = ct + 1;
            end
         end
      end
   end % static sealed protected methods
   
end % classdef
