function [proxies, constructors] = findProxies(storage, parentLocation)
; %#ok Undocumented
%findProxies 
%
%  PROXIES = FINDPROXIES(STORAGE, PARENTLOCATION)
%
% 

%  Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:20 $

error('distcomp:abstractstorage:AbstractMethodCall', 'Storage sub-classes MUST override this method');
