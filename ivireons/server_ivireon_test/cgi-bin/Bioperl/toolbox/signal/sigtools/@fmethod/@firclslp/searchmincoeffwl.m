function Hbest = searchmincoeffwl(this,args,varargin)
%SEARCHMINCOEFFWL Search for min. coeff wordlength.
%   This should be a private method.
%
%   If args doesn't have wl field: search for global minimum.
%
%   If args has wl field: search for a filter with coeff wordlength of at
%                         most wl.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:36:50 $

minordspec  = 'Fp,Fst,Ap,Ast';

designargs = {'fircls',...                
                'Zerophase',this.Zerophase,...
                'PassbandOffset',this.PassbandOffset};
           
Hbest = searchmincoeffwlword(this,args,minordspec,designargs,varargin{:});

% [EOF]
