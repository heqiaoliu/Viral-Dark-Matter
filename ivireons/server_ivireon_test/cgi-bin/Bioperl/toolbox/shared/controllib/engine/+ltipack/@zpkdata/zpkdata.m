classdef (Hidden = true) zpkdata < ltipack.ltidata
   % Class definition for @zpkdata (zero-pole-gain data)

   %   Author(s): P. Gahinet
   %   Copyright 1986-2008 The MathWorks, Inc.
   %	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:11 $
   properties
      z  % zero data
      p  % pole data
      k  % gain data
   end

   % RE: In ZPKDATA objects, Delay.IO is used to store the matrix of
   %     pairwise I/O delays.  ZPKDATA objects do not support fractional
   %     delays and their Z,P,K arrays are always commensurate with the
   %     I/O size

   methods
      function D = zpkdata(z,p,k,Ts)
         % Constructs @zpkdata instance
         if nargin==4
            [ny,nu] = size(k);
            D.z = z;
            D.p = p;
            D.k = k;
            D.Ts = Ts;
            D.Delay = ltipack.utDelayStruct(ny,nu,false);
         end
      end
      
      %-----------------------
      function D = checkData(D)
         % Checks that num,den data is consistent and NaN free. 
         
         % Determine I/O size from K array
         [Ny,Nu] = size(D.k);
         
         % Allow for scalar expansion of P array
         if (Ny~=1 || Nu~=1) && isscalar(D.p)
            % ZPK(Z,[1 2],1) (common denominator)
            D.p = repmat(D.p,Ny,Nu);
         end
         
         % I/O size consistency
         if ~isequal(size(D.z),size(D.p),[Ny Nu])
            ctrlMsgUtils.error('Control:ltiobject:zpkProperties4')
         end
         
         % Checks for NaNs
         if hasInfNaN(D.k)
            % Reduce to static gain
            D.k(:) = NaN;
            D.z(:) = {zeros(0,1)};
            D.p(:) = {zeros(0,1)};
            D.Delay.IO(:) = 0;
            D.Delay.Input(:) = 0;
            D.Delay.Output(:) = 0;
         end
      end
      
      %-----------------
      function [ny,nu] = iosize(D)
         % Returns I/O size.
         %   [NY,NU] = IOSIZE(SYS)
         %   S = IOSIZE(SYS) returns S = [NY NU].
         [ny,nu] = size(D.k);  % NOTE: Data defines I/O size
         if nargout<2
            ny = [ny nu];
         end
      end
      
   end
   
   methods(Static)
      function D = array(size)
         % Create a zpkdata array of a given size
         D = ltipack.zpkdata.newarray(size);
      end
      
      function D = loadobj(D)
         % Load filter for @ssdata
         if isfield(D.Delay,'Internal')
            % Pre-R2009b: Delay structure had Internal field for all model types
            D.Delay = rmfield(D.Delay,'Internal');
         end
      end
   end

            
   % Protected methods (utilities)
   methods(Access=protected)

      function [ro,co] = getOrder(D)
         % Computes order of ZPK models
         %
         %   [RO,CO] = GETORDER(D) computes the orders RO and CO
         %   of row-wise and column-wise state-space realizations of D
         z = D.z;
         p = D.p;
         k = D.k;
         [ny,nu] = size(k);

         % Compute orders of each I/O entries
         % RE: Zero entries contribute no dynamics
         np = cellfun('length',p);
         nz = cellfun('length',z);
         ioOrders = (k~=0) .* (max(nz,np) + (nz>np));

         % Determine row-wise order
         ro = 0;
         for i=1:ny,
            jdyn = find(ioOrders(i,:));  % dynamic entries
            if length(jdyn)>1 && isequal(p{i,jdyn}),
               % Common denominator
               ro = ro + ioOrders(i,jdyn(1));
            else
               ro = ro + sum(ioOrders(i,jdyn));
            end
         end

         % Determine column-wise order
         co = 0;
         for j=1:nu,
            idyn = find(ioOrders(:,j));   % dynamic entries
            if length(idyn)>1 && isequal(p{idyn,j})
               % Common denominator
               co = co + ioOrders(idyn(1),j);
            else
               co = co + sum(ioOrders(idyn,j));
            end
         end
      end

      %-------------------------------------------


   end

end
