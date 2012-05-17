function this = MATFileContainer(FileName)
% Defines properties for @MATFileContainer class
% (implements @ArrayContainer interface)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:14:06 $
this = hds.MATFileContainer;
this.FileName = FileName;
