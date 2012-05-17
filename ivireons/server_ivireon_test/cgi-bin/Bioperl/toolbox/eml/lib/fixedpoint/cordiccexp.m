function cis_out = cordiccexp(theta, niters)
% CORDICCEXP(theta, niters) Compute the CORDIC-based approximation to the complex exponential COS(theta) + jSIN(theta).

% Copyright 2009-2010 The MathWorks, Inc.
%#eml

eml.allowpcode('plain');
eml_prefer_const(theta);
eml_prefer_const(niters);

% Initialize output memory
real_vals_dbl = ones(length(theta(:)), 1);
cplx_vals_dbl = reshape(complex(real_vals_dbl, real_vals_dbl), size(theta));
if isa(theta, 'double')
    cis_out = eml.nullcopy(cplx_vals_dbl);
elseif isa(theta, 'single')
    cis_out = eml.nullcopy(single(cplx_vals_dbl));
else
    thetaNT      = numerictype(theta);
    ioWordLength = thetaNT.WordLength;
    ioFracLength = ioWordLength - 2;
    ioNT         = numerictype(1, ioWordLength, ioFracLength);
    cis_out      = eml.nullcopy(fi(cplx_vals_dbl, ioNT, 'fimath', []));
end

% Generate CORDIC SIN-COS code
[sin_out, cos_out] = cordicsincos(theta, niters);

% Copy real SIN-COS values to COMPLEX outputs
for idx = 1:length(sin_out(:))
    cis_out(idx) = complex(cos_out(idx), sin_out(idx));
end

end % function
