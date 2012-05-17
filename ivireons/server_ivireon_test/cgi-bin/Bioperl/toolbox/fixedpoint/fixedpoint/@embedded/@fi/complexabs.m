function Y = complexabs(A,varargin)
%COMPLEXABS Absolute value of complex fi object
%   The absolute value (Y) of a complex input (A) is related to its 
%   real and imaginary parts by
%       Y = sqrt(real(A)*real(A) + imag(A)*imag(A))
%
%   COMPLEXABS supports the following syntaxes:
%
%   Y = COMPLEXABS(A) returns a fi object with a value equal to the absolute
%   value of A and the same numerictype object as A. 
%   Intermediate quantities are calculated using the fimath associated with A. 
%
%   Y = COMPLEXABS(A,T) returns a fi object with a value equal to the 
%   absolute value of A and numerictype object T. 
%   Intermediate quantities are calculated using the fimath associated with
%   A. Data type propagation rules are followed (see Data Type Propagation 
%   Rules in 'help EMBEDDED.FI/ABS').
%
%   Y = COMPLEXABS(A,F) returns a fi object with a value equal to the
%   absolute value of A and the same numerictype object as A. 
%   Intermediate quantities are calculated using fimath object F.
%
%   Y = COMPLEXABS(A,T,F) returns a fi object with a value equal to the 
%   absolute value of A and with a numerictype object T. 
%   Intermediate quantities are calculated using fimath object F. Data type 
%   propagation rules are followed (see Data Type Propagation Rules in 
%   'help EMBEDDED.FI/ABS').
%
%
%   Example:
%     The following example illustrates typical usage of the COMPLEXABS
%     function.
%
%     a = fi(-1-i,1,16,15,'overflowmode','wrap')
%     t = numerictype(a.numerictype,'signed',false)
%     complexabs(a,t)
%     % Returns a fi object with a value of 1.4142, the specified unsigned
%     % numerictype, and the same fimath object as a. Intermediate 
%     % quantities are also calculated using the same fimath object as 
%     % a.
%
%   See also EMBEDDED.FI/ABS, EMBEDDED.FIMATH/ABS, 
%            EMBEDDED.NUMERICTYPE/ABS, FI, EMBEDDED.FI/REALABS

%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/10/24 19:04:05 $


[ntp, fmth, fimathSpecified] = parse_cabs_inputs(A,varargin{:});

if isscaledtype(ntp) && isempty(ntp.SignednessBool)
    % If Signedness is Auto (e.g. unspecified), then set the output type to
    % Unsigned. 
    ntp.SignednessBool = false;
end

if isfloat(ntp)
    if isdouble(ntp) || isdouble(A)
        Y = fi(abs(double(A)),ntp,fmth);
        Y.fimathislocal = false;
    else
        Y = fi(abs(single(A)),ntp,fmth);
        Y.fimathislocal = false;
    end
    return    
elseif isempty(A)
    Y = fi(double(real(A)),ntp,fmth);
    return
end

A_re = real(A); 
A_im = imag(A);

A_re_sq = fmth.mpy(A_re,A_re);
A_im_sq = fmth.mpy(A_im,A_im);

if isscaledtype(A) && issigned(A)
    ntp1 = numerictype(A_re_sq.numerictype,'signed',false);
    A_re_sq = reinterpretcast(A_re_sq,ntp1);
    A_im_sq = reinterpretcast(A_im_sq,ntp1);
end

A_abs_sq = fmth.add(A_re_sq,A_im_sq);

% Turn off fi:sqrt:outputrangetoosmall warning as it does not make sense in this context 
warning('off','fi:sqrt:outputrangetoosmall');
Y = sqrt(A_abs_sq,ntp,fmth);
if ~(A.fimathislocal) || fimathSpecified
    Y.fimathislocal = false;
else
    Y.fimath = A.fimath;
end
warning('on','fi:sqrt:outputrangetoosmall');


function [ntp_out, fmth_out, fimathSpecified] = parse_cabs_inputs(A,varargin)

fimathSpecified = false;

if isempty(varargin)
    % abs(A)                                                                                                                                
    fmth_out = A.fimath;
    ntp_out = A.numerictype;

elseif (nargin == 2)&&(isnumerictype(varargin{1}))
    % abs(A,T)
    fmth_out = A.fimath;
    ntp_out = varargin{1};

elseif (nargin == 2)&&(isfimath(varargin{1}))
    % abs(A,F)
    fmth_out = varargin{1};
    ntp_out = A.numerictype;
    fimathSpecified = true;
    
elseif (nargin == 3)&&(isnumerictype(varargin{1}))&&(isfimath(varargin{2}))
    % abs(A,T,F)
    ntp_out = varargin{1};
    fmth_out = varargin{2};
    fimathSpecified = true;
    
elseif (nargin == 3)&&(isnumerictype(varargin{2}))&&(isfimath(varargin{1}))
    % abs(A,F,T)
    fmth_out = varargin{1};    
    ntp_out = varargin{2};
    fimathSpecified = true;
    
else
    error('fixedpoint:fi:abs:complexabs:invalidOptionalIp',...
           ['This syntax is not supported by the abs function. See the '...
           'Function reference page in the Fixed-Point Toolbox '...
           'documentation for a list of supported syntaxes.']);
            
end

if (isboolean(A) || isboolean(ntp_out))
    error('fixedpoint:fi:abs:complexabs:nobooleanabs',...
     ['The abs function does not support complex fi objects when the fi'...
     ' object or the specified numerictype object is Boolean.']);
end

if (isslopebiasscaled(A.numerictype) || isslopebiasscaled(ntp_out))
    error('fixedpoint:fi:abs:complexabs:binarypointonly',...
     ['The abs function supports binary point-only scaling. For any '...
       'numerictype or fi object used with the abs function, the '...
       'fractional slope must be 1 and the bias must be zero.']);    
end

if isfloat(A)&&(~isfloat(ntp_out))
    ntp_out = A.numerictype;
end

if isscaleddouble(A)&&isfixed(ntp_out)
    ntp_out.datatype = 'ScaledDouble';
end
