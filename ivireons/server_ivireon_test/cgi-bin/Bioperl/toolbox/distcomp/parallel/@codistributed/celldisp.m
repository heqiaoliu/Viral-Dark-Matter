function celldisp(c,s)
%CELLDISP Display codistributed cell array contents
%   CELLDISP(C)
%   CELLDISP(C,NAME)
%   
%   See also CELLDISP, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:50:58 $

error(nargchk(1,2,nargin));
if isa(c, 'codistributed')
    localArray = getLocalPart(c);
else
    localArray = c;
end
if ~iscell(localArray)
    % This is the same error message as in base MATLAB.
    error('distcomp:codistributed:celldisp:notCellArray', 'Must be a cell array.');
end

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('celldisp', c); %#ok<DCUNK> private static

isloose = strcmp(get(0,'formatspacing'),'loose');

if nargin==1
    s = inputname(1); 
else
    s = distributedutil.CodistParser.gatherIfCodistributed(s);
end

if isempty(s), s = 'ans'; end
for i=1:numel(localArray),
  if iscell(localArray{i}) && ~isempty(localArray{i}),
     celldisp(localArray{i},[s subs(i,size(localArray), c)])
  else
    if isloose, disp(' '), end
    disp([s subs(i,size(localArray), c) ' ='])
    if isloose, disp(' '), end
    if ~isempty(localArray{i}),
      disp(localArray{i})
    else
      if iscell(localArray{i})
        disp('     {}')
      elseif ischar(localArray{i})
        disp('     ''''')
      elseif isnumeric(localArray{i})
        disp('     []')
      else
        [m,n] = size(localArray{i});
        fprintf('%0.f-by-%0.f %s\n',m,n,class(localArray{i}));
      end
    end
    if isloose, disp(' '), end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = subs(i,siz, array)
%SUBS Display subscripts
 totalSize = size(array);
 if isa(array, 'codistributed')
     arrDist = getCodistributor(array);
     part = arrDist.Partition;
 end
v = cell(size(siz));
[v{1:end}] = ind2sub(siz,i);
if isa(array, 'codistributed')
    v{arrDist.Dimension} = v{arrDist.Dimension} + sum(part(1:labindex-1));
end

if length(totalSize) == 2
    if totalSize(1) == 1
        v = v(2);
    elseif totalSize(2) == 1
        v = v(1);
    end
end

s = ['{' int2str(v{1})];
for i=2:length(v),
  s = [s ',' int2str(v{i})];  %#ok<AGROW> Only growing a trivial array.
end
s = [s '}'];
