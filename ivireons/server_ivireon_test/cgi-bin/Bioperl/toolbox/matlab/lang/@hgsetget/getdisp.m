%GETDISP    Specialized MATLAB object property display.
%   GETDISP is called by GET when GET is called with no output argument 
%   and a single input parameter H an array of handles to MATLAB objects.  
%   This method is designed to be overridden in situations where a
%   special display format is desired to display the results returned by
%   GET(H).  If not overridden, the default display format for the class
%   is used.
%
%   See also HGSETGET, HGSETGET/GET, HANDLE
 
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/10/31 06:20:24 $
%   Built-in function.