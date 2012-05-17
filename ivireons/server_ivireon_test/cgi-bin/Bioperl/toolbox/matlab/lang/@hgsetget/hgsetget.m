%HGSETGET   HG-style set and get for MATLAB objects.
%   The hgsetget class is an abstract class that provides an HG-style
%   property set and get interface.  hgsetget is a subclass of handle, so 
%   any classes derived from hgsetget are handle classes.  
%
%   classdef MyClass < hgsetget makes MyClass a subclass of hgsetget.
%
%   Classes that are derived from hgsetget inherit no properties but 
%   do inherit methods that can be overridden as needed.
%
%   HGSETGET methods:
%       SET      - Set MATLAB object property values.
%       GET      - Get MATLAB object properties.
%       SETDISP  - Specialized MATLAB object property display.
%       GETDISP  - Specialized MATLAB object property display.
%
%   See also HANDLE
 
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2009/12/07 20:42:45 $
%   Built-in class.
