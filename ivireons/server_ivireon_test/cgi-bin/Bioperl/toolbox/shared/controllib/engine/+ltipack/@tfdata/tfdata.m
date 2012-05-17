classdef (Hidden = true) tfdata < ltipack.ltidata
   % Class definition for @tfdata (transfer function data)

   %   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
   %	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:03 $

   % RE: In TFDATA objects, Delay.IO is used to store the matrix of
   %     pairwise I/O delays and Delay.Internal is not used.
   %     TFDATA objects do not support fractional delays and their
   %     NUM,DEN are always commensurate with the I/O size.
   % Rationale for limited delay support:
   %   * Internal delay support requires multiplying and inverting transfer
   %     matrices
   %   * Setting/getting the nominal NUM,DEN requires complex MINREAL
   %     operations to preserve order:
   %        set H11_nom:   H11(s) = H11_nom(s) - dH11(s)
   %        get H11_nom:   H11(s) + dH11(s) = (H11_nom - dH11) + dH11

   properties
      num  % numerator data
      den  % denominator data
   end

   methods
      function D = tfdata(num,den,Ts)
         % Constructs @tfdata instance
         if nargin==3
            [ny,nu] = size(num);
            D.num = num;
            D.den = den;
            D.Ts = Ts;
            D.Delay = ltipack.utDelayStruct(ny,nu,false);
         end
      end
      
      %-----------------------
      function D = checkData(D)
         % Checks that num,den data is consistent and NaN free. 
         
         % Determine I/O size from NUM array
         [Ny,Nu] = size(D.num);
         
         % Allow for scalar expansion of denominator
         if (Ny~=1 || Nu~=1) && isscalar(D.den)
            % TF(NUM,[1 0]) (common denominator)
            D.den = repmat(D.den,Ny,Nu);
         end
         
         % Check I/O size consistency
         if ~isequal(size(D.den),[Ny Nu])
            ctrlMsgUtils.error('Control:ltiobject:tfProperties2')
         end
         
         % Checks for NaNs
         Num = D.num;
         Den = D.den;
         for ctio=1:numel(Num)
            if hasInfNaN(Num{ctio}) || hasInfNaN(Den{ctio})
               D.num(:) = {NaN};
               D.den(:) = {1};
               D.Delay.IO(:) = 0;
               D.Delay.Input(:) = 0;
               D.Delay.Output(:) = 0;
               break
            end
         end
      end
      
      %-----------------
      function [ny,nu] = iosize(D)
         % Returns I/O size.
         %   [NY,NU] = IOSIZE(SYS)
         %   S = IOSIZE(SYS) returns S = [NY NU].
         [ny,nu] = size(D.num);  % NOTE: Data defines I/O size
         if nargout<2
            ny = [ny nu];
         end
      end
      
   end
   
   methods(Static)
      function D = array(size)
         % Create a tfdata array of a given size
         D = ltipack.tfdata.newarray(size);
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
      
      function [ro,co,D] = getOrder(D)
         % Computes order of TF models
         %
         %   [RO,CO] = GETORDER(D) computes the orders RO and CO of
         %   row-wise and column-wise state-space realizations of D
         %
         %   [RO,CO,D] = GETORDER(D) also returns the normalized
         %   transfer function with all leading denominator coefficients
         %   equal to 1
         num = D.num; %#ok<*PROP>
         den = D.den;
         [ny,nu] = size(num);

         % Normalize denominators and compute order of hij(s)
         % RE: Normalization needed to identify common den in
         % sys = [tf([1 2 5],-2*[1 2 2]) ; tf(-6*[1 0],4*[1 2 2])];
         Normalized = true;
         ioOrders = zeros(ny,nu);
         for ct=1:ny*nu
            nct = num{ct};
            dct = den{ct};
            den1 = dct(find(dct~=0,1));
            if den1~=1
               num{ct} = nct/den1;
               den{ct} = dct/den1;
               Normalized = false;
            end
            % Order of hij(s)
            if all(nct==0)
               % zero entries contribute no dynamics
               ioOrders(ct) = 0;
            elseif dct(1)~=0
               % proper
               ioOrders(ct) = length(dct)-1;
            else
               ioOrders(ct) = length(nct);
            end
         end

         % Determine row-wise order
         ro = 0;
         for i=1:ny,
            jdyn = find(ioOrders(i,:));  % non-static entries
            if length(jdyn)>1 && ltipack.isEqualDen(den{i,jdyn}),
               % Common denominator
               ro = ro + ioOrders(i,jdyn(1));
            else
               % Sum orders for hij(s), j = 1:nu
               ro = ro + sum(ioOrders(i,jdyn));
            end
         end

         % Determine column-wise order
         co = 0;
         for j=1:nu,
            idyn = find(ioOrders(:,j)); % non-static entries
            if length(idyn)>1 && ltipack.isEqualDen(den{idyn,j})
               % Common denominator
               co = co + ioOrders(idyn(1),j);
            else
               co = co + sum(ioOrders(idyn,j));
            end
         end

         if nargout==3 && ~Normalized
            D.num = num;
            D.den = den;
         end
      end

      %-------------------------------------------

   end

end

