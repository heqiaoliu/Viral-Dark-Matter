function D = setsubsys(D,rowIndex,colIndex,rhs)
% Modifies subsystem via SYS(i,j) = RHS.
% D and RHS are @ssdata objects with the same sampling time

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:51 $

%RE: Assumes SYS(I,J) is a subsystem of SYS (no size growing)
[ny,nu] = iosize(D);

if isequal(rhs,[])
   % SYS(i,:) = [] or SYS(:,j) = []
   iscolon = strcmp({rowIndex,colIndex},':');
   rowSel = 1:ny;
   colSel = 1:nu;
   if all(iscolon)
      % sys(:,:) = [] produces a 0-by-nu system as for matrices
      rowSel = [];
   elseif iscolon(1)
      colSel(colIndex) = [];
   else
      rowSel(rowIndex) = [];
   end
   % Use GETSUBSYS to get structurally minimal number of internal delays
   % RE: Do not eliminate any state to be consistent with SUBSREF
   D = getsubsys(D,rowSel,colSel);

else
   % SYS(I,J) = matrix or SYS(I,J) = ss model
   rhsSize = iosize(rhs);  % watch for internal delays   
   if strcmp(rowIndex,':') && strcmp(colIndex,':')
      % Optimized code for sys(:,:,ind) = rhs
      if all(rhsSize==1) && (nu>1 || ny>1)
         % Scalar expansion
         rhs = iorep(rhs,iosize(D));
      end
      D = rhs;
      
   elseif ~isempty(rowIndex) && ~isempty(colIndex)
      % Map ROWINDEX and COLINDEX to integer indices
      if ischar(rowIndex),
         rowIndex = 1:ny;
      elseif isa(rowIndex,'logical'),
         rowIndex = find(rowIndex);
      end
      if ischar(colIndex),
         colIndex = 1:nu;
      elseif isa(colIndex,'logical'),
         colIndex = find(colIndex);
      end
      
      % Handle the case where rowIndex or colIndex have repeated indices (g374594)
      [~,ir] = unique(rowIndex,'last');
      [~,ic] = unique(colIndex,'last');
      if length(ir)<length(rowIndex) || length(ic)<length(colIndex)
         % Reduce to equivalent assignment with nonrepeated indices
         rowIndex = rowIndex(ir);    colIndex = colIndex(ic);
         rhs = LocalGetSubSys(rhs,ir,ic);
         rhsSize = iosize(rhs);
      end
      
      % Resolve input and output delays for new I/O channels (initialized
      % to NaN)
      D = assignDelay(D,rowIndex,colIndex,rhs);
      
      % Expand scalar RHS
      nar = length(rowIndex);  % no. assigned rows
      nac = length(colIndex);  % no. assigned cols
      if all(rhsSize==1) && (nar>1 || nac>1)
         rhs = iorep(rhs,[nar,nac]);
      elseif nar~=rhsSize(1)
         % RE: Keep this for cases where RHS is 1xN or Nx1 in which case
         % the IOSIZE assignment in LTI/SUBSASGN may not fail
         ctrlMsgUtils.error('Control:ltiobject:subsasgn5')
      elseif nac~=rhsSize(2)
         ctrlMsgUtils.error('Control:ltiobject:subsasgn6')
      end

      % Find row and column indices not affected by assignment, and
      % implicitly permute I/Os so that the assignment looks like
      %    [sys11  sys12 ;         [sys11  sys12;
      %     sys21  sys22 ]   -->    sys21   rhs ]
      frows = 1:ny;  frows(rowIndex) = [];  % fixed rows
      fcols = 1:nu;  fcols(colIndex) = [];  % fixed rows
      rperm = [frows , rowIndex];           % row permutation
      cperm = [fcols , colIndex];           % column permutation

      if isempty(frows) && isempty(fcols),
         % Full reassignment
         D = rhs;
      elseif isempty(frows)
          % 2-Block case (e.g. Case for ny = 0)
          % Assemble result as [sys11 , rhs]
          sys11 = getsubsys(D,rperm,fcols,'smin');
          D = iocat(2,sys11,rhs);
      elseif isempty(fcols)
          % 2-Block Case (e.g. Case for nu = 0)
          % Assemble result as [sys11 ; rhs]
          sys11 = getsubsys(D,frows,cperm,'smin');
          D = iocat(1,sys11,rhs);
      else
         % Compute structural order of [[sys11 sys12] ; [sys21 rhs]]
         sysfr = LocalGetSubSys(D,frows,cperm);
         sys21 = LocalGetSubSys(D,rowIndex,fcols);
         Naug1 = size(sysfr.a,1) + size(sys21.a,1);

         % Compute structural order of [[sys11 ; sys21] , [sys12 ; rhs]]
         sysfc = LocalGetSubSys(D,rperm,fcols);
         sys12 = LocalGetSubSys(D,frows,colIndex);
         Naug2 = size(sysfc.a,1) + size(sys12.a,1);

         % Construct minimum-order realization for modified lhs
         if Naug1<=Naug2,
            % Assemble result as [[sys11 , sys12] ; [sys21 , rhs]]
            D = iocat(1,sysfr,iocat(2,sys21,rhs));
         else
            % Assemble result as [[sys11 ; sys21] , [sys12 ; rhs]]
            D = iocat(2,sysfc,iocat(1,sys12,rhs));
         end
      end

      % Undo I/O permutation
      D.b(:,cperm) = D.b(:,1:nu);
      D.d(:,cperm) = D.d(:,1:nu);
      D.Delay.Input(cperm,:) = D.Delay.Input;
      D.c(rperm,:) = D.c(1:ny,:);
      D.d(rperm,:) = D.d(1:ny,:);
      D.Delay.Output(rperm,:) = D.Delay.Output;
   end

end


%-------- Local Functions ------------------------

function D = LocalGetSubSys(D,rowIndex,colIndex)
% Wrapper around GETSUBSYS to discard all states when rowIndex
% or colIndex is empty (see TSUBS:lvlTwo2)
nr = length(rowIndex);
nc = length(colIndex);
if nr==0 || nc==0
   % Blast all states and delays
   D = ltipack.ssdata([],zeros(0,nc),zeros(nr,0),zeros(nr,nc),[],D.Ts);
else
   D = getsubsys(D,rowIndex,colIndex,'smin');
end
