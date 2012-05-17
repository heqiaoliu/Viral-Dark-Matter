function majority = getMajority(cdfId)
%cdflib.getMajority Return variable majority of CDF
%   majority = cdflib.getMajority(cdfId) returns the variable majority, either
%   'ROW_MAJOR' or 'COLUMN_MAJOR', of the CDF identified by cdfId.
%
%   Note:  The majority setting is an external mechanism.  CDF data is
%   always imported into MATLAB with the fastest-varying dimension first.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetMajority.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       majority = cdflib.getMajority(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setMajority.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:59 $

majority = cdflibmex('getMajority',cdfId);
