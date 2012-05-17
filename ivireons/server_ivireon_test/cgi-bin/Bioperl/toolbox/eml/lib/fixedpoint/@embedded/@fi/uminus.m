function yfi = uminus(xfi)
% Embedded MATLAB Library function for @fi/uminus.
%
% UMINUS(A) will return the unary minus of A

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/uminus.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.8 $  $Date: 2009/05/14 16:52:44 $

if eml_ambiguous_types
    yfi = eml_not_const(zeros(size(xfi)));
    return;
end

% Get the numerictype and fimath of xfi
tx = eml_typeof(xfi);
fx = eml_fimath(xfi);

if isfixed(xfi)
  % FI objects with Fixed datatype
  ty = numerictype(tx,'Bias',-tx.Bias);
  doSaturate = eml_const(isequal(fx.OverflowMode,'saturate'));
  if ~isslopebiasscaled(tx) && ~(tx.Signed) && doSaturate
    yfireim = eml_dress(uint32(zeros(size(xfi))),ty,fx);
    if isreal(xfi)
      yfi = eml_fimathislocal(yfireim,eml_fimathislocal(xfi));
      return;
    else
      yfi = eml_fimathislocal(complex(yfireim,yfireim),eml_fimathislocal(xfi));
      return;
    end
  end
elseif isfloat(xfi)
  % True Double or True Single FI
  ty = tx;
else
  % FI datatype not supported
  eml_fi_assert_dataTypeNotSupported('UMINUS','fixed-point,double, or single');
end

% call eml_uminus
yfi = eml_uminus(xfi,ty,fx);

%----------------------------------------------------
