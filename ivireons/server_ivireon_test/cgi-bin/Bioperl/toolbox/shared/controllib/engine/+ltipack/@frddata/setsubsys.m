function D = setsubsys(D,rowIndex,colIndex,rhs)
% Modifies subsystem via SYS(i,j) = RHS.
% D and RHS are @frddata objects with the same sampling time

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:03 $

%RE: Assumes SYS(I,J) is a subsystem of SYS (no size growing)
if isempty(rhs)
   % SYS(i,:) = [] or SYS(:,j) = []
   D.Response(rowIndex,colIndex,:) = [];
   D.Delay.IO(rowIndex,colIndex) = [];
   iscolon = strcmp({rowIndex,colIndex},':');
   if iscolon(2)
      % Row deletion
      % Note: sys(:,:) = [] produces a 0-by-nu system as for matrices
      D.Delay.Output(rowIndex,:) = [];
   else      
      % Column deletion
      D.Delay.Input(colIndex,:) = [];
   end
else
   % SYS(I,J) = matrix or SYS(I,J) = frd model
   if strcmp(rowIndex,':') && strcmp(colIndex,':')
      % Optimized code for sys(:,:,ind) = rhs
      if all(iosize(rhs)==1) && any(iosize(D)>1)
         % Scalar expansion
         rhs = iorep(rhs,iosize(D));
      end
      D = rhs;
   elseif ~isempty(rowIndex) && ~isempty(colIndex)
      % Delay handling
      [D,rhs] = assignDelay(D,rowIndex,colIndex,rhs);
      % Update response data
      if all(iosize(rhs)==1)
         % Find out size of assigned LHS block for proper scalar expansion
         tmp = zeros(iosize(D));
         R = repmat(rhs.Response,size(tmp(rowIndex,colIndex)));
      else
         R = rhs.Response;
      end
      D.Response(rowIndex,colIndex,:) = R;            
   end
end
