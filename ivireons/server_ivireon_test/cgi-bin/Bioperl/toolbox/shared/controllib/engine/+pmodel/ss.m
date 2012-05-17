classdef ss < pmodel.Generic
   % Parameterization of linear state-space models.
   %
   %   The PMODEL.SS class parameterizes state-space models of the form
   %       dx/dt = Ax + Bu + Ke
   %         y   = Cx + Dy + e
   %  
   %   M = pmodel.ss(A,B,C,D,K) returns a parametric state-space model M
   %   where the model parameters are initialized to the values A,B,C,D,K.
   %
   %   M = pmodel.ss(A,B,C,D) constructs a parametric state-space model M
   %   without noise input e. This is equivalent to setting M.k to empty.
   %
   %   See also PMODEL.TF, PMODEL.PID
   

   %   Author(s): P. Gahinet, Rajiv Singh
   %   Copyright 2009-2010 The MathWorks, Inc.
   %	 $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:36:46 $
   
   properties (Access = public)
      % A matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the state matrix A,
      % to initialize A, or to fix/free specific entries of A.
      a
      % B matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the input-to-state
      % matrix B, to initialize B, or to fix/free specific entries of B.
      b
      % C matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the state-to-output
      % matrix C, to initialize C, or to fix/free specific entries of C.
      c
      % D matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the feedthrough
      % matrix D, to initialize D, or to fix/free specific entries of D.
      % For example, you can fix D to zero by typing 
      %    M.D.Value = 0;  M.D.Free = false;
      d
      % K matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of K, initialize K,
      % or to fix/free specific entries of K. You can also set K to []
      % to eliminate the noise input e.
      k
      % State names (string vector, default = empty string for all states).
      %
      % You can set this property to:
      %   * A string for first-order models, for example, 'position'
      %   * A string vector for models with two or more states, for example,
      %     {'position' ; 'velocity'}
      % Use the empty string '' for unnamed states.
      StateName
      % State units (string vector, default = empty string for all states).
      %
      % Use this property to keep track of the units each state is expressed in.
      % You can set "StateUnit" to:
      %   * A string for first-order models, for example, 'm/s'
      %   * A string vector for models with two or more states, for example,
      %    {'m' ; 'm/s'}
      StateUnit
   end
   
   methods (Access = protected)
      
      % PARAMETER SERIALIZATION INTERFACE (PMODEL.GENERIC)
      function ps = getParamSet(M)
         ps = [M.a; M.b; M.c; M.d; M.k];
      end
      
      function M = setParamSet(M,ps)
         M.a = ps(1);  M.b = ps(2);  M.c = ps(3);  M.d = ps(4);
         if numel(ps)>4
            M.k = ps(5);
         end
      end   
   end
   
   % PUBLIC METHODS
   methods
      
      function M = ss(a,b,c,d,k)
         % Constructs pmodel.ss instance
         ni = nargin;
         if ni==0
            return
         end
         M.a = param.Continuous('a',a);
         M.b = param.Continuous('b',b);
         M.c = param.Continuous('c',c);
         M.d = param.Continuous('d',d);
         if ni>4
            M.k = param.Continuous('k',k);
         end
      end
            
   end
   
   methods (Hidden)
      
      function nx = order(M)
         % Number of states
         if isempty(M.a)
            nx = 0;   % for ltiblock.ss()
         else
            nx = size(M.a.Value,1);
         end
      end
      
      function s = iosize(M,dim)
         % I/O sizes
         s = size(M.d.Value);
         if nargin>1
            if dim<3
               s = s(dim);
            else
               s = 1;
            end
         end
      end
      
      function M1 = iocat(dim, M1, M2)
         % Concatenate models along input (2) or output (1) dimension.
         nx1 = order(M1); nx2 = order(M2);
         kFlag = ~(isempty(M1.k) || isempty(M2.k));
         M1.a = pmodel.appendParameter(M1.a,M2.a,'a');
         if dim==1
            % Output concatenation.
            % Input sizes of M1 and M2 are assumed to match.
            M1.b = pmodel.catParameter(1,M1.b,M2.b,'b');
            M1.c = pmodel.appendParameter(M1.c,M2.c,'c');
            if kFlag
               M1.k = pmodel.appendParameter(M1.k,M2.k,'k');
            end
         else
            % Input concatenation.
            % Output sizes of M1 and M2 are assumed to match.
            M1.b = pmodel.appendParameter(M1.b,M2.b,'b');
            M1.c = pmodel.catParameter(2,M1.c,M2.c,'c');
            if kFlag
               M1.k = pmodel.catParameter(1,M1.k,M2.k,'k');
            end
         end
         M1.d = pmodel.catParameter(dim,M1.d,M2.d,'d');
         % State names and units
         if ~(isempty(M1.StateName) && isempty(M2.StateName))
            M1.StateName = [ltipack.fullstring(M1.StateName,nx1) ; ...
               ltipack.fullstring(M2.StateName,nx2)];
         end
         if ~(isempty(M1.StateUnit) && isempty(M2.StateUnit))
            M1.StateUnit = [ltipack.fullstring(M1.StateUnit,nx1) ; ...
               ltipack.fullstring(M2.StateUnit,nx2)];
         end
         
      end
      
      %-------------------------------------------
      function M = getsubsys(M,rowIndex,colIndex)
         % Extracts submodel.
         M.b = pmodel.getSubParameter(M.b,':',colIndex);
         M.c = pmodel.getSubParameter(M.c,rowIndex,':');
         M.d = pmodel.getSubParameter(M.d,rowIndex,colIndex);
         if ~isempty(M.k)
            M.k = pmodel.getSubParameter(M.k,':',rowIndex);
         end
      end
      
      %-------------------------------------------------------------------
      function M = checkDataSize(M)
         % Checks size consistency for A,B,C,D,K parameters.
         Nx = size(M.a.Value,1);
         [Ny,Nu] = size(M.d.Value);
         if ~(isequal(getSize(M.a),[Nx Nx]) && isequal(getSize(M.b),[Nx Nu]) && ...
               isequal(getSize(M.c),[Ny Nx]) && isequal(getSize(M.d),[Ny Nu]) && ...
               (isempty(M.k) || isequal(getSize(M.k),[Nx Ny])))
            ctrlMsgUtils.error('Control:pmodel:ssbadsize')
         elseif ~(isequal(M.StateName,[]) || numel(M.StateName)==Nx)
            ctrlMsgUtils.error('Control:ltiobject:ssProperties3','StateName')
         elseif ~(isequal(M.StateUnit,[]) || numel(M.StateUnit)==Nx)
            ctrlMsgUtils.error('Control:ltiobject:ssProperties3','StateUnit')
         end
      end
      
      %--------------------------------------------------------------------
      function M = checkDataType(M)
         % Validates data type of A,B,C,D,K parameters.
         M.a = pmodel.checkParameter(M.a,'a');
         M.b = pmodel.checkParameter(M.b,'b');
         M.c = pmodel.checkParameter(M.c,'c');
         M.d = pmodel.checkParameter(M.d,'d');
         if ~isequal(M.k,[])
            M.k = pmodel.checkParameter(M.k,'k');
         end
         M.StateName = ltipack.checkStateInfo(M.StateName,'StateName');
         M.StateUnit = ltipack.checkStateInfo(M.StateUnit,'StateUnit');
      end
   end   
end

