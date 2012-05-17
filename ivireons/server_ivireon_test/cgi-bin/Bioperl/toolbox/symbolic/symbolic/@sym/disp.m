function disp(X)
%DISP   Displays a sym as text.
%   DISP(S) displays the scalar or array sym,
%   without printing the sym name.

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
if isa(X.s,'maplesym')
    disp(X.s,inputname(1));
    return;
end

loose = isequal(get(0,'FormatSpacing'),'loose');
sz = size(X);
if prod(sz) == 0
    disp('[ empty sym ]')
elseif all(sz == 1)
    allstrs = mupadmex('symobj::allstrs',X.s,0);
    allstrs = strrep(allstrs(2:end-1),'_Var','');
    if ~isempty(strfind(allstrs,'_symans'))
        warning('symbolic:sym:disp:UndefinedVariable','The result cannot be displayed due a previously interrupted computation or out of memory. Run ''reset(symengine)'' and rerun the commands to regenerate the result.');
        return;
    end
    disp(allstrs);
else
    % Find maximum string length of the elements of a X
    p = sz;
    d = length(p);
    allstrs = mupadmex('symobj::allstrs', X.s, 0);
    allstrs = strrep(allstrs,'_Var','');
    if ~isempty(strfind(allstrs,'_symans'))
        warning('symbolic:sym:disp:UndefinedVariable','The result cannot be displayed due a previously interrupted computation or out of memory. Run ''reset(symengine)'' and rerun the commands to regenerate the result.');
        return;
    end
    allstrs = allstrs(2:end-3); % 3 covers the trailing #!"
    strs = regexp(allstrs,'#!','split');
    strs = reshape(strs,sz);
    lengths = cellfun('length',strs);
    while ndims(lengths) > 2
        lengths = max(lengths,[],ndims(lengths));
    end
    len = max(lengths,[],1);
    
   for k = 1:prod(p(3:end))
      if d > 2
         if loose, disp(' '), end
         disp([inputname(1) '(:,:,' int2strnd(k,p(3:end)) ') = '])
         if loose, disp(' '), end
      end
      % Pad each element with the appropriate number of blanks
      for i = 1:p(1)
         str = '[';
         for j = 1:p(2)
            s = strs{i,j,k};
            s(s=='`') = [];
            str = [str blanks(len(j)-length(s)+1) s ','];
         end
         str(end) = ']';
         if p(2) == 1; str = str(2:end-1); end
         disp(str)
      end
   end
end
if loose, disp(' '), end
collectGarbage(symengine);

% ------------------------

function s = int2strnd(k,p)
s = '';
k = k-1;
for j = 1:length(p)
   d = mod(k,p(j));
   s = [s int2str(d+1) ','];
   k = (k - d)/p(j);
end
s(end) = [];
