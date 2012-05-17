function [s,g] = designflfhparameq(this,N,G0,G,GB,Gb,Flow,Fhigh,varargin)
%DESIGNBWPARAMEQ   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:28:38 $

[w0,Dwb] = parameqbandedge(Flow*pi,Fhigh*pi,1);
if Fhigh ==1, w0=pi; end

[s,g] = designbwparameq(this,N,G0,G,GB,Gb,w0,Dwb,varargin{:});

% [EOF]
