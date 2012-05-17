function Hd = thisdesign(d)
%THISDESIGN Design a filter with GREMEZ 

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:26:45 $

[F, A, W, args] = getarguments(d.ResponseTypeSpecs, d);

if isspecify(d),
    sp  = convertspecialprops(d);
    
    % If there are any special frequency points, insert them before the
    % weights.  Otherwise just add the extra args after the weights.
    if isempty(sp), args = {W, args{:}};
    else,           args = {sp, W, args{:}}; end
    
    % If there are any constraints (IAEs or CEMs) add them to the end.
    con = getconstraints(d);
    if ~isempty(con), args = {args{:}, con}; end
    
else
    args = {W, args{:}};
end

order = convertorder(d);

args = {args{:}, {get(d, 'DensityFactor')}};

phase = get(d, 'Phase');
if ~strcmpi(phase, 'linear'),
    args = {args{:}, sprintf('%sphase', lower(phase(1:3)))};
end

if isdynpropenab(d, 'FIRType'),
    firtype = get(d, 'FIRType');
    if ~strcmpi(firtype, 'unspecified'), args = {args{:}, lower(firtype)}; end
end

b = feval(designfunction(d), order, F, A, args{:});

% Construct object
Hd = dfilt.dffir(b);

% [EOF]
