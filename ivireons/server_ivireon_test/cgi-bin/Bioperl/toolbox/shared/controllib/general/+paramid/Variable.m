classdef Variable < paramid.ID
   % VARIABLE parameter identifier for a workspace variable
   
   % Copyright 2009 The MathWorks, Inc.
   % $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:00 $
   
   properties (GetAccess = public, SetAccess = public)
      Locations = cell(0,1);
   end % properties
   
   methods (Access = public)
      function this = Variable(name, path, locations)
         % Constructor
         %
         % paramid.Variable(name, [path], [locations])
         ni = nargin;
         
         % Superclass constructor arguments.
         args = {};
         if (ni == 1)
            args{1} = name;
         elseif (ni >= 2)
            args{1} = name;
            args{2} = path;
         end
         this = this@paramid.ID(args{:});
         
         if (ni > 0)
            error( nargchk(1, 3, ni, 'struct') )
            
            % Default arguments
            if (ni < 3), locations = cell(0,1); end
            
            try
               % Set properties, using scalar expansion if necessary.
               this.Locations = locations;
            catch E
               ctrlMsgUtils.error('Controllib:modelpack:InvalidArgument', 'LOCATIONS')
            end
         end
      end
   end % public methods
   
   methods
      function this = set.Locations(this, value)
         if ~iscellstr(value)
            ctrlMsgUtils.error('Controllib:modelpack:CellArrayOfStringsProperty','Locations')
         end
         % Make it a column array.
         this.Locations = value(:);
      end
      function value = properties(this)  %#ok<MANU>
         value = properties('paramid.ID');
         value = [value; 'Locations'];
      end
   end % property methods
   
end % classdef
