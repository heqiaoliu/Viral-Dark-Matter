function display(X)
%DISPLAY Display function for syms.

%   Copyright 1993-2009 The MathWorks, Inc.

if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
if isa(X.s,'maplesym')
    display(X.s,inputname(1));
    return;
end

loose = isequal(get(0,'FormatSpacing'),'loose');
if loose, disp(' '), end
if ndims(X) <= 2
   disp([inputname(1) ' =']);
   if loose, disp(' '), end
   disp(X)
else
   p = size(X);
   p = p(3:end);
   for k = 1:prod(p)
      if loose, disp(' '), end
      disp([inputname(1) '(:,:,' int2strnd(k,p) ') = '])
      if loose, disp(' '), end
      sub = privsubsref(X,':',':',k);
      disp(sub);
   end
end

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
