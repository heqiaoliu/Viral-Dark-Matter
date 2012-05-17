classdef Parameter
   %Abstract parent class for all parameter objects
   %
   %    Parameter objects are typically used to create parametric models and
   %    to estimate or tune the free parameters in such models.
   
   % Copyright 2009-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.1.2.1 $ $Date: 2010/06/28 14:19:27 $
   
   properties (Hidden = true, GetAccess = private, SetAccess = private)
      Size_  = [0 0];
      Value_ = [];
   end % private properties
   
   properties (Hidden = true, GetAccess = protected, SetAccess = protected)
      pID = [];
   end % protected properties
      
   properties (Abstract = true, Dependent)
      %VALUE Parameter value
      %
      %    The Value property specifies a value for the parameter. The
      %    dimension of the Value property is fixed on construction.
      Value;
   end % abstract properties
   
   properties(Dependent)
      %NAME Parameter name
      %
      %    The Name property is a read-only string that is set on object
      %    construction.
      Name;
      
      %INFO Structure array specifying parameter units and labels
      %
      %    The Info property is a structure array with Label and Unit fields. 
      %    The array dimension matches the dimension of the Value property.
      %
      %    Use the Info property to store parameter units and labels that
      %    describe the parameter, e.g., 
      %      p = param.Continuous('K',eye(2));
      %      p.Info(1,1).Unit  = 'N/m'; 
      %      p.Info(1,1).Label = 'spring constant';
      Info;
   end %Public dependent properties
   
   properties (Hidden = true, GetAccess = protected, SetAccess = protected)
      Version = param.version;
      Info_   = [];
   end % protected properties
   
   methods (Hidden = true, Access = protected)
      function this = Parameter(ID)
         % Constructor
         %
         % param.Value(name)
         % param.Value(id)
         ni = nargin;
         if ni > 0
            error( nargchk(1, 1, ni, 'struct') )
            
            % Parse first input argument.
            if ischar(ID)
               ID = paramid.Variable(ID);
            elseif ~(isa(ID, 'paramid.ID') || isempty(ID))
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgument', 'NAME/ID')
            end
         else
            % Properties for no-argument constructor.
            ID = [];
         end
         
         % Set properties, using scalar expansion if necessary.
         this.pID         = ID;
      end
      
      function this = setSize(this,sz)
         % Set private Size_ property. Used to fix dimensions of parameter
         % value and dependent properties
         this.Size_ = sz;
      end
      function val = getPValue(this)
         %Return private Value_ property
         val = this.Value_;
      end
      function this = setPValue(this,val)
         %Set private Value_ property.
         this.Value_ = val;
      end
      
      function bool = isDefaultValue(this,prop)
         % Method to determine whether a property value has been modified
         % from it's default value. Returns true if the property is
         % unmodified false otherwise.
         %
         % bool = isDefaultValue(this, prop)
         %
         % Inputs:
         %   prop - one of {'Info'}
         %
         
         if strcmp(prop,'Info')
            bool = isempty(this.Info_);
         else
            ctrlMsgUtils.error('Controllib:modelpack:InvalidArgument', prop)
         end
      end
   end % hidden protected methods
   
   methods(Hidden = true)
      function disp(this)
         paramid.array_display(this);
      end
      function display(this)
         paramid.array_display(this, inputname(1));
      end
      function sz = getSize(this)
         %Return private Size_ property
         sz = this.Size_;
      end
      function props = properties(this)
         %Make sure Name property appears as first in property list
         props = properties(class(this));
         idx = strcmp(props,'Name');
         props = [props(idx); props(~idx)];
      end
   end % Hidden public methods
   
   methods
      %Get/set methods for dependent Name property
      function name = get.Name(this)
         if ~isempty(this.pID)
            name = this.pID.getFullName;
         else
            name = '';
         end
      end
      function this = set.Name(this,value)
         try
            this = pSetName(this,value);
         catch E
            throwAsCaller(E)
         end
      end
      %Get/set methods for dependent Info property
      function this = set.Info(this,value)
         try
            if isempty(value)
               this.Info_ = [];
            elseif isstruct(value) && isfield(value,'Label') && isfield(value,'Unit')
               if isequal(size(value), this.getSize)
                  this.Info_ = value;
               else
                  ctrlMsgUtils.error('Controllib:modelpack:CannotFormatValueToSize','Info')
               end
            else
               ctrlMsgUtils.error('Controllib:modelpack:errInfoProperty')
            end
         catch E
            throwAsCaller(E)
         end
      end
      function value = get.Info(this)
         if isempty(this.Info_)
            %Property has not been initialized, return default
            sz = this.Size_;
            if prod(sz) == 0
               %Quick return as no elements in Value property
               value = zeros(sz);
               return
            end
            %Set Label for each element to Name(1,1), Name(1,2), etc.
            vLabel = cell(sz);
            if iscell(this.Value_)
               lParen = '{';
               rParen = '}';
            else
               lParen = '(';
               rParen = ')';
            end
            n = prod(sz);
            if n > 1
               indices = paramid.array_indices(sz);
               name = this.Name;
               for ct=1:n
                  coord = sprintf('%d,', indices(ct,:));
                  vLabel{ct} = sprintf('%s%s%s%s', name, lParen, coord(1:end-1), rParen);
               end
            else
               vLabel{1} = this.Name;
            end
            %Set Unit to empty for each element
            vUnit = cell(this.Size_);
            [vUnit(:)] = deal({''});
            value = struct('Label',vLabel,'Unit',vUnit);
         else
            value = this.Info_;
         end
      end
   end % property methods
   
   methods(Hidden = true)
      function ID = getID(this)
         % Returns the associated identifier object.
         ID = this.pID;
      end
   end % hidden methods
   
   methods (Hidden = true, Access = protected)
      function this = pSetName(this,value) %#ok<INUSD>
         ctrlMsgUtils.error('Controllib:modelpack:errReadOnlyProperty','Name',class(this));
      end
   end % Hidden protected methods
   
   methods (Hidden = true, Sealed, Access = protected)
      function value = formatValueToSize(this, value, prop)
         % Formats the value to match the size of the variable.
         sz = this.Size_;
         % Reshape value if needed.
         if ~isequal(size(value), sz)
            if isscalar(value)
               % Scalar expansion.
               value = value(ones(sz));
            elseif isvector(value) && length(value) == prod(sz)
               % Vector with same number of elements, but possibly different orientation.
               value = reshape(value, sz);
            else
               ctrlMsgUtils.error('Controllib:modelpack:CannotFormatValueToSize', prop)
            end
         end
      end
   end % hidden sealed protected methods
   
end % classdef
