function yfi = eml_fi_eps_lsb(xfi,fcnName,check4scalarInput)
% Embedded MATLAB Library function for private use.

% Embedded MATLAB Library function to perform core computations for @fi/eps
% and lsb. It returns eps - or lsb, which is same as eps - of the fi xfi
%
% xfi               - fi object
% fcnName           - name of public function calling this helper function 
%                     (i.e. eps or lsb - case insensitive)
% check4scalarInput - true/false to indicate whether non-scalar inputs are
%                     allowed by the public function.
% 

% Copyright 2007-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.5 $  $Date: 2009/05/14 16:52:39 $

eml.extrinsic('upper');
eml.extrinsic('sprintf');
 
eml_allow_mx_inputs;

% Check for nargin and assert if not 3
eml_assert(nargin==3,['Internal error. EML_FI_EPS_LSB helper function ' ...
                    'requires 3 input arguments.']);

% Core computations
Tx = eml_typeof(xfi);
Fx = eml_fimath(xfi);

if isfixed(xfi)
    if check4scalarInput
        eml_assert( isscalar(xfi),eml_const( sprintf(['The fixed-point %s function is not supported for a fi input that is not a scalar.'],upper(fcnName)) ) );
    end
    ytemp = eml_dress(uint32(1),Tx,Fx);
    if eml_const(eml_fimathislocal(xfi))
        yfi = ytemp;
    else
        yfi = eml_fimathislocal(ytemp,false);
    end
elseif isfloat(xfi)
    xTemp = eml_cast(xfi,eml_fi_getDType(xfi));
    epsX  = eps(xTemp);
    yfi   = eml_fimathislocal(eml_cast(epsX,Tx,Fx),false);
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported(upper(fcnName),'fixed-point,double, or single');
end

%----------------------------------------------------
