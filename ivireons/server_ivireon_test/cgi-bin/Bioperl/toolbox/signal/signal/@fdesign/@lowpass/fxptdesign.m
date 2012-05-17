function varargout = fxptdesign(this, method, varargin)
%FXPTDESIGN   Design a minimum word length filter.
%   FXPTDESIGN(D, M, VARARGIN) Design the filter using the method in the string
%   M on the specs D.  

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:35:56 $

% Test if Fixed-Point Toolbox is installed
if ~isfixptinstalled,
     error(generatemsgid('fixptTbxRq'), ...
        'The Fixed-Point Toolbox must be available to design a minimum word length filter.');
end

% Error out if not FIR
if isempty(find(designmethods(this,'fir'),method)),
     error(generatemsgid('FIRonly'), ...
        'The design method must be FIR.');
end

% Minimum wordlength design (i.e. Smart default for CoeffWordLength)
Hd = design(this,method,varargin{:});
Hd = minwordfir(this,Hd,'noiseShaping',ns,newargs{:});

% [EOF]
