function id = create(filename)
%cdflib.create Create CDF file
%   cdfId = cdflib.create(filename) creates a new CDF file and returns the 
%   file ID.
%
%   This function corresponds to the CDF library C API routine 
%   CDFcreateCDF.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.open, cdflib.close, cdflib.delete.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:31 $

id = cdflibmex('create',filename);
