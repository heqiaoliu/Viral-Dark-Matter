function [T, errid, errmsg] = eml_fi_computeDivideType(Ta, Tb)
%eml_fi_computeDivideType Embedded MATLAB helper function to compute the quotient numerictype for A/B and A./B
%
%    [T, errid, errmsg] = eml_fi_computeDivideType(Ta, Tb) computes the
%    quotient numerictype T for A/B and A./B where Ta is numerictype(A) if A
%    is a fi object or class(A) if A is not a fi object, and Tb is
%    numerictype(B) if B is a fi object or class(B) if B is not a fi object.
%
%    If an error occurs, then the error id and error message are returned in
%    errid and errmsg, respectively.
%
%    This helper function is an Embedded MATLAB front-end for
%    embedded.fi/computeDivideType. 
%
%    See also embedded.fi/computeDivideType.

%   Thomas A. Bryan and Becky Bryan, 30 December 2008
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:56:05 $

T = [];
[a, errid, errmsg] = parse_inputs(Ta);
if isempty(errid)
    [b, errid, errmsg] = parse_inputs(Tb);
    if isempty(errid)
        [T, errid, errmsg] = computeDivideType(a,b);
    end
end

function [x, errid, errmsg] = parse_inputs(Tx)
errid = '';
errmsg = '';

% Parse the input types
if isnumerictype(Tx)
    % numerictype object
    x = fi([],Tx);
elseif ischar(Tx)
    % String that defines the class
    x = feval(Tx,0);
else
    % Invalid input to this function
    errid = 'fi:computeDivideType:InvalidInput';
    errmsg = 'Invalid input to @fi/computeDivideType.';
end    
