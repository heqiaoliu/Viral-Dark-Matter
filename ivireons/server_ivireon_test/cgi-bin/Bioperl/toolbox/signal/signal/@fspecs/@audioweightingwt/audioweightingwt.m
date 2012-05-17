function this = audioweightingwt(varargin) 
%AUDIOWEIGHTINGWT  Construct an AUDIOWEIGHTINGWT object.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:41:57 $

this = fspecs.audioweightingwt;

set(this, 'ResponseType', 'Audio Weighting Filter');
