function names = getConstantNames()
%cdflib.getConstantNames Return list of constant names
%   names = cdflib.getConstantNames() returns a list of names of constants 
%   known to the CDF library.
%
%   Example:  names = cdflib.getConstantNames();
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.getConstantValue.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:53 $

names = cdflibmex('getConstantNames');
