classdef(Hidden = true) String < param.Parameter
   %
   
   %Construct a string parameter
   %
   
   % Copyright 2009-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.1.2.1 $ $Date: 2010/06/28 14:19:30 $
   
   properties(Dependent)
      Value
   end % Implemented superclass abstract properties
   
   methods (Access = public)
      function this = String(name, value)
         % Construct a param.String object
         %
         % param.String(name, [value])
         % param.String(id, [value])
         % param.String(value) value must be cell to distinguish from String(name)
         % param.String
         ni = nargin;
         if (ni > 0)
            error( nargchk(1, 2, ni, 'struct') )
            
            % Default arguments
            if (ni < 2), value = ''; end
            
            % Parse first input argument.
            if iscellstr(name)
               ID = [];
               if numel(name) == 1
                  value = name{1};
               else
                  value = name;
               end
            elseif ischar(name)
               ID = paramid.Variable(name);
            elseif isa(name, 'paramid.ID')
               ID = name;
            else
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgument', 'NAME/ID')
            end
         else
            % Properties for no-argument constructor.
            ID = [];
            value = '';
         end
         
         % Call superclass constructor first.
         this = this@param.Parameter(ID);
         
         %Set parameter dimensions, do this before setting actual value to
         %avoid dimension check
         if iscellstr(value)
            sz = size(value);
         else
            sz = [1 1];
         end
         this = setSize(this, sz);
         % Set value property
         this.Value  = value;
      end
   end % public methods
   
   methods
      %Get/Set methods for implemented abstract dependent Value property
      function this = set.Value(this,newvalue)
         try
            %Value must be a string or cell array of strings
            if ~ischar(newvalue) &&  ~iscellstr(newvalue)
               ctrlMsgUtils.error('Controllib:modelpack:StringArrayProperty','Value')
            end
            %Value cannot change dimension
            if iscellstr(newvalue)
               newSize = size(newvalue);
            else
               newSize = [1 1];
            end
            if isequal(getSize(this),newSize)
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
   end % property methods
end
