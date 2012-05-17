function dispsys(D,Inames,Onames,LeftMargin)
%DISPLAY  Pretty-print for state-space models.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:55 $

try
   % Compute matrices with delays set to zero
   [a,b,c,d,~,e] = getABCDE(D);
   % Print matrices
   printsys(a,b,c,d,e,Inames,Onames,D.StateName,LeftMargin);
   if any(D.Delay.Internal)
      disp(ctrlMsgUtils.message('Control:ltiobject:DispSS1',LeftMargin))
   end
catch %#ok<CTCH>
   % Singular algebraic loops
   nx = order(D);
   [ny,nu] = iosize(D);
   disp(' ')
   if nx==0
      disp(ctrlMsgUtils.message('Control:ltiobject:DispSS3',LeftMargin,'d',ny,nu))
   else
      disp(ctrlMsgUtils.message('Control:ltiobject:DispSS3',LeftMargin,'a',nx,nx))
      disp(ctrlMsgUtils.message('Control:ltiobject:DispSS3',LeftMargin,'b',nx,nu))
      disp(ctrlMsgUtils.message('Control:ltiobject:DispSS3',LeftMargin,'c',ny,nx))
      disp(ctrlMsgUtils.message('Control:ltiobject:DispSS3',LeftMargin,'d',ny,nu))
      if ~isempty(D.e)
         disp(ctrlMsgUtils.message('Control:ltiobject:DispSS3',LeftMargin,'e',nx,nx))
      end
   end
   disp(ctrlMsgUtils.message('Control:ltiobject:DispSS2',LeftMargin))
end

% Display delay info
printdelay(D.Delay,LeftMargin);
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function printsys(a,b,c,d,e,ulabels,ylabels,xlabels,LeftMargin)
%PRINTSYS  Print system in pretty format.
% 
%   PRINTSYS is used to print state space systems with labels to the
%   right and above the system matrices.
%
%   PRINTSYS(A,B,C,D,E,ULABELS,YLABELS,XLABELS) prints the state-space
%   system with the input, output and state labels contained in the
%   cellarrays ULABELS, YLABELS, and XLABELS, respectively.  
%   
%   PRINTSYS(A,B,C,D) prints the system with numerical labels.
%
%   See also: PRINTMAT
nx = size(a,1);
[ny,nu] = size(d);

if isempty(ulabels) || isequal('',ulabels{:}),
   for i=1:nu,
      ulabels{i} = sprintf('u%d',i);
   end
else
   for i=1:nu,
      if isempty(ulabels{i}),  ulabels{i} = '?';  end
   end
end

if isempty(ylabels) || isequal('',ylabels{:}),
   for i=1:ny,
      ylabels{i} = sprintf('y%d',i);
   end
else
   for i=1:ny,
      if isempty(ylabels{i}),  ylabels{i} = '?';  end
   end
end

if isempty(xlabels)
   xlabels = strseq('x',1:nx);
else
   for i=1:nx,
      if isempty(xlabels{i}),  xlabels{i} = '?';  end
   end
end


disp(' ')
if isempty(a),
   % Gain matrix
   printmat(d,[LeftMargin 'd'],ylabels,ulabels);
else
   printmat(a,[LeftMargin 'a'],xlabels,xlabels);
   printmat(b,[LeftMargin 'b'],xlabels,ulabels);
   printmat(c,[LeftMargin 'c'],ylabels,xlabels);
   printmat(d,[LeftMargin 'd'],ylabels,ulabels);
   if ~isempty(e),
      printmat(e,[LeftMargin 'e'],xlabels,xlabels);
   end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function printdelay(Delay,offset)
% Displays time delays
Skip = false;

% Input delays
id = Delay.Input;
if any(id),
   Skip = true;
   disp([ctrlMsgUtils.message('Control:ltiobject:DispSS4',offset) sprintf(' %0.3g ',id')])
end

% Output delays
od = Delay.Output;
if any(od),
   Skip = true;
   disp([ctrlMsgUtils.message('Control:ltiobject:DispSS5',offset) sprintf(' %0.3g ',od')])
end

% Internal delays
lftd = Delay.Internal;
if ~isempty(lftd),
   Skip = true;
   disp([ctrlMsgUtils.message('Control:ltiobject:DispSS6',offset) sprintf(' %0.3g ',lftd')])
end

if Skip
   disp(' ')
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function printmat(a,name,rlab,clab)
%PRINTMAT Print matrix with labels.
%   PRINTMAT(A,NAME,RLAB,CLAB) prints the matrix A with the row labels
%   RLAB and column labels CLAB.  NAME is a string used to name the
%   matrix.  RLAB and CLAB are cell vectors of strings.
CWS = get(0,'CommandWindowSize');      % max number of char. per line
MaxLength = round(.9*CWS(1));

[nrows,ncols] = size(a);
len = 12;    % Max length of labels
Space = ' ';
a(a==0) = 0;  % so that -0 display as 0

% Print name
if ~isempty(name),
   disp([name,' = ']),
end

% Empty case
if (nrows==0) || (ncols==0),
   if (nrows==0) && (ncols==0),
      disp('     []')
   else
      disp(ctrlMsgUtils.message('Control:ltiobject:DispSS7','     ',nrows,ncols));
   end
   disp(' ')
   return
end

% Row labels
RowLabels = strjust(strvcat(' ',rlab{:}),'left'); %#ok<VCAT>
RowLabels = RowLabels(:,1:min(len,end));
RowLabels = [Space(ones(nrows+1,1),ones(3,1)),RowLabels];

% Construct matrix display
Columns = cell(1,ncols);
prec = 3 + isreal(a);
for ct=1:ncols,
   clab{ct} = clab{ct}(:,1:min(end,len));
   col = [clab(ct); cellstr(deblank(num2str(a(:,ct),prec)))];
   col = strrep(col,'+0i','');  % xx+0i->xx
   Columns{ct} = strjust(strvcat(col{:}),'right'); %#ok<VCAT>
end

% Equalize column width
lc = cellfun('size',Columns,2);
lcmax = max(lc)+2;
for ct=1:ncols,
   Columns{ct} = [Space(ones(nrows+1,1),ones(lcmax-lc(ct),1)) , Columns{ct}];
end

% Display MAXCOL columns at a time
maxcol = max(1,round((MaxLength-size(RowLabels,2))/lcmax));
for ct=1:ceil(ncols/maxcol)
   disp([RowLabels Columns{(ct-1)*maxcol+1:min(ct*maxcol,ncols)}]);
   disp(' ');
end
end
