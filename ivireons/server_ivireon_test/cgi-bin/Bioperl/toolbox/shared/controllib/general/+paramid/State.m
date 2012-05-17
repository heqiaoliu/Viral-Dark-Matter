classdef State < paramid.ID
   % STATE parameter identifier for a state
   
   % Copyright 2009 The MathWorks, Inc.
   % $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:52:59 $
   
   properties (GetAccess = public, SetAccess = public)
      Ts = 0;
   end % properties
   
   methods (Access = public)
      function this = State(name, path, Ts)
         % Constructor
         %
         % paramid.State(name, [path], [Ts])
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
            if (ni < 3), Ts = 0; end
            
            % Set properties, using scalar expansion if necessary.
            this.Ts = Ts;
         end
      end
      
      function name = getFullName(this)
         % Returns the unique full name of the variable identified by object.
         name = this.Name;
         
         % Construct the full name
         if ~isempty(this.Path)
            name = sprintf('%s/%s', this.Path, name);
         end
      end
   end % public methods
   
   methods
      function this = set.Ts(this, value)
         if ~isreal(value) || ~isscalar(value) || (value<0) ...
               || isnan(value) || ~isfinite(value)
            ctrlMsgUtils.error('Controllib:modelpack:NonNegativeRealScalar','Ts')
         end
         this.Ts = value;
      end
      function value = properties(this) %#ok<MANU>
         value = properties('paramid.ID');
         value = [value; 'Ts'];
      end
   end % property methods
   
end % classdef
