function out = pElementwiseUnaryOp( fcn, in, opt_opFcn )
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:27:28 $

if nargin < 3
    infixOp = '';
    doInfix = false;
else
    infixOp = opt_opFcn;
    doInfix = true;
end

if ( isempty(in) )
    out = in;
else
    
    try
        out = pElementwiseOp( fcn, doInfix, infixOp, in );
    catch E
        throwAsCaller(E);
    end
    
end

end
