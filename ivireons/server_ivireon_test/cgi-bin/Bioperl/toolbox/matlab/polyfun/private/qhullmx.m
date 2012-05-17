function [t,v] = qhullmx(varargin)
% QHULLMX gateway function for Qhull.
%   For example,
%   T = QHULLMX(X,'d ','QJ') this is equivalent to T = DELAUNAYN(X,{'QJ'}).
%   [T,V] = QHULLMX(X,'v ','QJ') is equivalent to [T,V] = VORONOIN(X,{'QJ'}).
%
%   QHULLMX is based on Qhull.  See QHULL for Copyright information.
%
%   See also QHULL, DELAUNAYN, VORONOIN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.7.6.3 $ $Date: 2006/05/19 20:17:47 $
%# mex  

error('MATLAB:qhullmx:MexFileNotFound', 'mex-file not found')
