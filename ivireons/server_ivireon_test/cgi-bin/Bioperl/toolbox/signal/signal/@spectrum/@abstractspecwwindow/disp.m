function disp(this)
%DISP Spectrum object display method.
  
%   Author: P. Pacheco
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:37 $

s  = get(this);
fn = fieldnames(s);
N  = length(fn);

props = propstoaddtospectrum(this.Window);

idx1 = find(strcmpi(fn,'WindowName'));
idx2 = [];
if ~isempty(props),
    for k=1:length(props),
        idx2(k) = find(strcmpi(fn,props{k}));
    end
end
% Reorder the fields so that windowname and windowparam are last.
fn1 = fn([idx1 idx2]); 
fn([idx1 idx2]) = [];
fn = [fn; fn1];

for i=1:N,
    snew.(fn{i}) = getfield(s, fn{i});
end

% Make sure the two NFFT properties are together.
props = reorderprops(this);
if any(strcmpi(fn,'Nfft')),
    snew = reorderstructure(snew,props{:});
end
disp(snew)

% [EOF]
