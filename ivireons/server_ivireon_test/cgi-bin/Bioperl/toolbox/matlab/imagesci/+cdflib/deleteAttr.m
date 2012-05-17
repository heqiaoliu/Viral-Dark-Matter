function deleteAttr(cdfId,attrNum)
%cdflib.deleteAttr Create attribute
%   cdflib.deleteAttr(cdfId,attrNum) deletes the attribute specified by 
%   attrNum in the CDF specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFdeleteAttr.  
%
%   Example:
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       attrNum = cdflib.getAttrNum(cdfid,'SampleAttribute');
%       cdflib.deleteAttr(cdfid,attrNum);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createAttr, cdflib.getAttrNum.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:35 $

cdflibmex('deleteAttr',cdfId,attrNum);
