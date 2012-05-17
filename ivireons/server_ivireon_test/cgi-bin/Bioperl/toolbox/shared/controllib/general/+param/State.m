classdef(Hidden = true) State < param.Continuous
   %
   
   %Construct a model state parameter
   
   % Copyright 2009-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.1.2.1 $ $Date: 2010/06/28 14:19:29 $
   
   properties(Dependent)
      dxFree
      dxValue
   end % properties
   
   properties(GetAccess = protected, SetAccess = protected)
      dxFree_
      dxValue_
   end % protected properties
   
   methods (Access = public)
      function this = State(ID, value)
         % Construct a param.State object
         %
         % param.State(id, [value])
         % param.State
         ni = nargin;
         if (ni > 0)
            error( nargchk(1, 2, ni, 'struct') )
            
            % Default arguments
            if (ni < 2), value = 0; end
            
            % Make sure ID property is for a state
            if ~isa(ID, 'paramid.State')
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgument', 'NAME/ID')
            end
         else
            % Properties for no-argument constructor.
            ID = paramid.State;
            value = 0;
         end
         
         % Call superclass constructor.
         this = this@param.Continuous(ID, value);
         
      end
   end % public methods
   
   methods
      %Get/set methods for dependent dxFree property
      function this = set.dxFree(this, value)
         try
            this.dxFree_ = this.formatLogicalValue(value,'dxFree',true);
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.dxFree(this)
         if isempty(this.dxFree_)
            %Property has not been initialized, return default
            val = true(getSize(this));
         else
            val = this.dxFree_;
         end
      end
      %Get/set methods for dependent dxValue property
      function this = set.dxValue(this, value)
         try
            this.dxValue_ = this.formatValueMinMax(value,'dxValue',0);
         catch E
            throwAsCaller(E)
         end
      end
      function val = get.dxValue(this)
         if isempty(this.dxValue_)
            %Property has not been initialized, return default
            val = zeros(getSize(this));
         else
            val = this.dxValue_;
         end
      end
      
      function value = properties(this) %#ok<MANU>
         %Get all the properties of the super class
         value = properties('param.Continuous');
         %Put Name property at the top of the list, the Info property at 
         %the end of list and add dxXXXX properties
         idx = [strcmp(value,'Name'), strcmp(value,'Info')];
         value = [...
            value(idx(:,1)); ...
            value(~(idx(:,1)|idx(:,2))); ...
            'dxValue'; 'dxFree'; ...
            value(idx(:,2))];
      end
   end % property methods
   
   methods(Hidden = true)
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
         
         if ~isa(p,'param.State')
            ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'p', 'catParameter')
         end
         if nargin < 4,
            ID = this.getID;
         else
            if ~ischar(name)
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommand', 'name', 'catParameter')
            end
            ID = paramid.State(name);
         end
         
         %Concatenate value property and create new parameter object
         try
            newValue = cat(dim,this.Value,p.Value);
         catch E
            throw(E)
         end
         pNew = param.State(ID,newValue);
                  
         %Concatenate ancillary properties
         pNew = catAncillaryProps(this,p,dim,pNew);
      end
      
      function pNew = subsrefParameter(this,idx,name)
         % SUBSREFPARAMETER create a new parameter by sub-indexing into a parameter
         %
         % pNew = this.subsrefParameter(idx,[name])
         % pNew = this.subsrefParameter({idx1,....,idxN},[name])
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
            ID = this.getID;
         else
            if ~ischar(name)
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgumentForCommandForCommand', 'name', 'subsrefParameter')
            end
            ID = paramid.State(name);
         end
            
         %Construct a new parameter object from the elements of this object
         try
            NewValue = this.Value(idx{:});
         catch E
            throw(E)
         end
         pNew = param.State(ID,NewValue);
                           
         %Copy ancillary properties
         pNew = subsrefAncillaryProps(this,pNew,idx);
      end
      
   end %public hidden methods
   
   methods(Access = protected)
      function bool = isDefaultValue(this, prop)
         % Method to determine whether a property value has been modified
         % from it's default value. Returns true if the property is
         % unmodified false otherwise.
         %
         % bool = isDefaultValue(this, prop)
         %
         % Inputs:
         %   prop - one of {'dxFree'}
         %
         % See also param.Continuous.isDefaultValue
         %
         
         allProp = {'dxFree','dxValue'};
         if any(strcmp(allProp,prop))
            %Default value indicated by empty private property
            bool = isempty(this.(strcat(prop,'_')));
         else
            try 
               %Call parent class method
               bool = isDefaultValue@param.Continuous(this,prop);
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
         
         %Call parent method
         pNew = catAncillaryProps@param.Continuous(this,p,dim,pNew);
      
         %If they are not default copy ancillary properties
         %
         %For performance reasons call this.dxFree_ directly instead of 
         %using isDefaultValue. Use p.isDefaultValue as need access to
         %private property.
         if ~(isempty(this.dxFree_) && isDefaultValue(p,'dxFree'))
            pNew.dxFree = cat(dim,this.dxFree,p.dxFree);
         end
         if ~(isempty(this.dxValue_) && isDefaultValue(p,'dxValue'))
            pNew.dxValue = cat(dim,this.dxValue,p.dxValue);
         end
      end
      
      function pNew = subsrefAncillaryProps(this,pNew,idx)
         %Convenience method to copy indexed property values to a new
         %paramete object. Called by subsrefParameter. 
         %
         % This method is separated from subsrefParameter so that subclasses
         % can call it in overloaded subsrefParameter methods.
         
         %Call parent method
         pNew = subsrefAncillaryProps@param.Continuous(this,pNew,idx);
         
         %If they are not default copy ancillary properties
         if ~isempty(this.dxFree_)
            pNew.dxFree = this.dxFree(idx{:});
         end
         if ~isempty(this.dxValue_)
            pNew.dxValue = this.dxValue(idx{:});
         end
      end
      function this = subsasgnAncillaryProps(this,p,idx)
         % Convenience method to assign indexed elements of this object from
         % a passed parameter object. Called by subsasgnParameter
         %
         % This method is separated from subsasgnParameter so that subclasses
         % can call it in overloaded subsasgnParameter methods.
         
         %Call parent method
         this = subsasgnAncillaryProps@param.Continuous(this,p,idx);
         
         %If they are not default assign ancillary properties
         %
         %For performance reasons call this.dxFree_ directly instead of 
         %using isDefaultValue. Use p.isDefaultValue as need access to
         %private property.
         if ~(isempty(this.dxFree_) && isDefaultValue(p,'dxFree'))
            v = this.dxFree(idx{:});
            v(:) = p.dxFree(:);
            this.dxFree(idx{:}) = v;
         end
         if ~(isempty(this.dxValue_) && isDefaultValue(p,'dxValue'))
            v = this.dxValue(idx{:});
            v(:) = p.dxValue(:);
            this.dxValue(idx{:}) = v;
         end
      end
   end % protected methods
   
end % classdef
