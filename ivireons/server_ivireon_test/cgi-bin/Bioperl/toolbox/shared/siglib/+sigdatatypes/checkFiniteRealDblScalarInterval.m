function checkFiniteRealDblScalarInterval(h, prop, value, interval, boundary)
%CHECKFINITEREALDBLSCALARINTERVAL Check if value is a finite real double
%scalar within a given interval
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.
%
%   Interval is a 1x2 vector specifying the beginning and the end of the
%   interval. Boundary is a string specifying whether it is open or close
%   interval at the boundary.  Boundary can be any of the following four
%   cases: [ 'cc' | 'co' | 'oo' | 'oc' ] where 'c' represents close
%   interval and 'o' represents open interval.
%
%   Example:
%       sigdatatypes.checkFiniteRealDblScalarInterval('foo','x',...
%           0.5,[0 1],'cc');

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/08/22 20:31:50 $

scflag = (boundary(1)=='c');
ecflag = (boundary(2)=='c');
sval = interval(1);
eval = interval(2);
if scflag
    startbracket = '[';
else
    startbracket = '(';
end
   
if ecflag
    endbracket = ']';
else
    endbracket = ')';
end

if ~isscalar(value) || ~isa(value, 'double') || isinf(value) || ...
        isnan(value) || ~isreal(value) || value < sval || value > eval ...
        || ((value==sval)&&(~scflag)) || ((value==eval)&&(~ecflag))
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite real '...
            'scalar double within %c%5.2f %5.2f%c.'], prop, h,...
            startbracket, sval, eval, endbracket);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite real '...
            'scalar double within %c%5.2f %5.2f%c.'], prop, class(h),...
            startbracket, sval, eval, endbracket);
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFiniteRealDblScalarInterval', msg));
end
%---------------------------------------------------------------------------
% [EOF]