function out = pElementwiseBinaryOp( fcn, in1, in2, opt_opFcn )
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:27:26 $

if nargin < 4
    doInfix = false;
    infixOp = '';
else
    doInfix = true;
    infixOp = opt_opFcn;
end

if ~( isequal(size(in1),size(in2)) || isscalar(in1) || isscalar(in2) )
    tothrow = MException('empty:operation','Matrix dimensions must agree.');
    throwAsCaller(tothrow);
elseif isempty(in1) && isscalar(in2)
    out = in1;
elseif isscalar(in1) && isempty(in2)
    out = in2;
else
    
    try
        out = pElementwiseOp( fcn, doInfix, infixOp, in1, in2 );
    catch E
        throwAsCaller(E);
    end
    
end

end
