classdef Port < paramid.ID
   % PORT parameter identifier for a port
   
   % Copyright 2009 The MathWorks, Inc.
   % $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:52:58 $
   
   properties
      Type       = [];
      PortNumber = [];
   end % properties
   
   methods (Access = public)
      function this = Port(name, path, type, portno)
         % Constructor
         %
         % paramid.Port(name, [path], [type], [portno])
         ni = nargin;
         
         % Superclass constructor arguments.
         args = {};
         if (ni == 1)
            args{1} = name;
         elseif (ni >= 2)
            args{1} = name;
            args{2} = path;
         end
                  
         if (ni > 0)
            error( nargchk(1, 4, ni, 'struct') )
            
            % Default arguments
            if (ni < 3) || isempty(type), type = 'None'; end
            if (ni < 4), portno = 1; end
            
         else
            type = 'None';
            portno = 1;
         end
         
         %Call superclass constructor first
         this = this@paramid.ID(args{:});
         
         % Set properties, using scalar expansion if necessary.
         this.Type = type;
         this.PortNumber = portno;
      end
      
      function name = getFullName(this)
         % Returns the unique full name of the variable identified by object.
         name = this.Name;
         if isempty(name)
            return
         end
         
         % Construct the full name
         if ~isnan(this.PortNumber)
            name = sprintf('%s:%d', name, this.PortNumber);
         end
         if ~isempty(this.Path)
            if iscellstr(this.Path)
               path = this.Path{1};
               for ct = 1:numel(this.Path)-1
                  path = sprintf('%s|%s',path,this.Path{ct+1});
               end
            else
               path = this.Path;
            end
            name = sprintf('%s/%s', path, name);
         end
      end
   end % methods
   
   methods
      function this = set.PortNumber(this, value)
         if ~isreal(value) || ~isscalar(value) || (~isnan(value) && value<=0) ...
               || rem(value,1) ~= 0
            ctrlMsgUtils.error('Controllib:modelpack:PositiveIntegerProperty','PortNumber')
         end
         this.PortNumber = value;
      end
      function this = set.Type(this, value)
         if ~any( strcmpi(value, {'Input','Output','InOut','OutIn','None'}) )
            ctrlMsgUtils.error('Controllib:modelpack:errPortType')
         end
         this.Type = value;
      end
      function value = properties(this) %#ok<MANU>
         value = properties('paramid.ID');
         value = [value; 'Type'; 'PortNumber'];
      end
   end % property methods
   
end % classdef
