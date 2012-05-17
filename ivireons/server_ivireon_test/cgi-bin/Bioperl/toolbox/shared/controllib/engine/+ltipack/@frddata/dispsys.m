function dispsys(D,Inames,Onames,LineMax,LeftMargin,Units)
%DISPLAY  Pretty-print for frd models

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:36:31 $
freq = D.Frequency;
resp = D.Response;
[ny,nu,nf] = size(D.Response); %#ok<NASGU>

% I/O channel names
AllEmptyNames = true;
for inputIndex = 1:nu
   if isempty(Inames{inputIndex})
      Inames{inputIndex} = ctrlMsgUtils.message('Control:ltiobject:DispFRD1',inputIndex);
   else
      Inames{inputIndex} = ctrlMsgUtils.message('Control:ltiobject:DispFRD2',Inames{inputIndex});
      AllEmptyNames = false;
   end
end
for outputIndex = 1:ny
   if isempty(Onames{outputIndex})
      Onames{outputIndex} = ctrlMsgUtils.message('Control:ltiobject:DispFRD3',outputIndex);
   else
      AllEmptyNames = false;
   end
end
CompactDisp = (ny==1 && nu==1 && AllEmptyNames);
if CompactDisp
   Onames = {ctrlMsgUtils.message('Control:ltiobject:DispFRD4')};
end

% Display frequency
[fCol,fColWidth] = colPrint(freq,ctrlMsgUtils.message('Control:ltiobject:DispFRD5',Units));
colSpace = repmat('  ',[size(fCol,1),1]);
marginSpace = repmat(' ',size(fCol,1),2+length(LeftMargin));
for inputIndex = 1:nu
   col = [marginSpace fCol colSpace];
   colWidth = fColWidth + 3;
   header = sprintf('\n%s%s\n',LeftMargin,Inames{inputIndex});
   for outputIndex = 1:ny
      [newCol,newWidth] = ...
         colPrint(resp(outputIndex,inputIndex,:), Onames{outputIndex});
      if ((colWidth+newWidth+1>LineMax) || (newWidth+fColWidth+1 > LineMax))
         disp(header);
         disp(col);
         col = [fCol colSpace];
         colWidth = fColWidth + 1;
      end
      col = [col colSpace newCol]; %#ok<AGROW>
      colWidth = colWidth+newWidth+1;
   end % outputIndex
   if colWidth > fColWidth+1  % col includes response data
      if ~CompactDisp
         disp(header)
      else
         disp(' ')
      end
      disp(col);
   end
end

% Display delay info
disp(' ')
printdelay(D.Delay,LeftMargin);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function printdelay(Delay,offset)
% Displays time delays
Skip = false;

% Input delays
id = Delay.Input;
if any(id),
   Skip = true;
   if isscalar(id)
      disp(sprintf('%sInput delay: %0.5g',offset,id));
   else
      disp(sprintf('%sInput delays (listed by channel): %s',offset,sprintf('%0.3g  ',id')))
   end
end

% Output delays
od = Delay.Output;
if any(od),
   Skip = true;
   if isscalar(od)
      disp(sprintf('%sOutput delay: %0.5g',offset,od));
   else
      disp(sprintf('%sOutput delays (listed by channel): %s',offset,sprintf('%0.3g  ',od')))
   end
end

% I/O delays
iod = Delay.IO;
if any(iod(:)),
   Skip = true;
   if isscalar(iod)
      disp(sprintf('%sI/O delay: %0.5g',offset,iod));
   elseif all(iod(:)==iod(1))
      disp(sprintf('%sI/O delay (for all I/O pairs): %0.5g',offset,iod(1)))
   else
      disp(sprintf('%sI/O delays:',offset));
      siod = evalc('disp(iod)');
      disp(siod(1:end-2))
   end
end

if Skip
   disp(' ')
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [column,colWidth] = colPrint(vector,title)
% Return character matrix COLUMN for display using TITLE as a header

if isempty(vector)
   column = '';

elseif ischar(vector)
   column = vector;

else
   vector = vector(:);
   n = length(vector);
   isFinite = isfinite(vector);
   realVector = real(vector);
   imagVector = imag(vector);
   anyReal = any(realVector~=0 | ~isFinite); % for Inf's and NaN's
   anyImag = any(imagVector~=0 & isFinite);

   if anyReal
      realColumn = alignDecimal(realVector);  % align decimals
   elseif anyImag
      realColumn = char(zeros(n,0));
   else
      realColumn = repmat('0',n,1);
   end

   if ~anyImag
      imagColumn = char(zeros(n,0));
   elseif anyReal
      blanks = repmat(' ',n,1);
      imagSigns = repmat('+',n,1);
      imagSigns(imagVector<0) = '-';
      % align decimals, adding i's only for non-zero entries
      imagColumn = alignDecimal(abs(imagVector),'i');
      imagColumn = [blanks imagSigns blanks imagColumn];  % combine signs, numbers
   else
      imagColumn = alignDecimal(imagVector,'i');
   end

   % concatenate real and imag columns
   column = [realColumn imagColumn];

end

% add title above column
colSize = size(column);
title = [title; repmat('-',[1 size(title,2)])]; % add -------
titleSize = size(title);
if titleSize(2) > colSize(2)
   leading = ceil((titleSize(2) - colSize(2))/2);
   trailing = floor((titleSize(2) - colSize(2))/2);
   column = [repmat(' ',[colSize(1) leading]) ...
      column repmat(' ',[colSize(1) trailing])];
elseif titleSize(2) < colSize(2)
   leading = ceil((colSize(2) - titleSize(2))/2);
   trailing = floor((colSize(2) - titleSize(2))/2);
   title = [repmat(' ',[titleSize(1) leading]) ...
      title repmat(' ',[titleSize(1) trailing])];
end
column = [title; column];

colWidth = size(column,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function charMatrix = alignDecimal(vector,extra)
% take a vector of numbers, and an 'extra' string
% return the character matrix of numbers with the decimal points aligned,
% and the 'extra' string appended to each line.

if nargin == 1
   extra = '';
end
floatMin = 1e-3;
floatMax = 1e4;
maxRatio = 1e6;
vector = vector(:);
n = length(vector);

finiteVector = abs(vector(isfinite(vector) & vector~=0));
charCells = cell(n,1);

if isempty(finiteVector) ...
      || min(finiteVector)<floatMin ...
      || max(finiteVector)>floatMax ...
      || max(finiteVector)>maxRatio*min(finiteVector)
   % Exponential format
   for ct=1:n
      charCells{ct} = sprintf('%.3e',vector(ct));
   end
elseif all(floor(finiteVector)==finiteVector)
   % Integer format
   for ct=1:n
      charCells{ct} = sprintf('%d',vector(ct));
   end
else
   % Floating point format
   for ct=1:n
      charCells{ct} = sprintf('%.4f',vector(ct));
   end
end

% add extra characters
charMatrix = [strjust(char(charCells),'right') repmat(extra,[n 1])];
end
