%SETDISP    Specialized MATLAB object property display.
%   SETDISP is called by SET when SET is called with no output argument 
%   and a single input parameter H an array of handles to MATLAB objects.  
%   This method is designed to be overridden in situations where a
%   special display format is desired to display the results returned by
%   SET(H).  If not overridden, the default display format for the class
%   is used.
%
%   See also HGSETGET, HGSETGET/SET, HANDLE
 
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/10/31 06:20:25 $