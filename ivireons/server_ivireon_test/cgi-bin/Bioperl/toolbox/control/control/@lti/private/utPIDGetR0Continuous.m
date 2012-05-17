function [KiC, wC, SignAtInf, zpkR0Func] = utPIDGetR0Continuous(Model,PlotNeeded)
% Singular frequency based PI Tuning sub-routine (Continuous).
%
% This function finds local minimums and maximums of imag{1/Model(jw)}*w.
% The corresponding frequencies are wC and KiC = r0(wC) defines Ki segments
% in which the number of unstable poles remain constant. 
%
% Input arguments
%   Model:      plant model
%
% Output arguments
%   KiC:        critical Ki values as r0(wC)
%   wC:         critical frequencies (where extremes of r0(w) occur)
%   SignAtInf:  sign of r0(w) at w=inf
%   zpkR0Func:  use imag(freqresp(zpkR0Func,w))*w or imag(evalfr(zpkR0Func,j*w))*w to obtain r0(w)
%
% Note:
%   1. Model should not contain any differentiator
%   2. w=0 is always a critical frequency (because of no differentiator) 
%   3. wC is sorted. 

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:08 $

% ------------------------------------------------------------------------
%% since r0(jw)=imag{1/G(jw)}*w=-real{jw/G(jw)}, we can compute critical
%% frequencies using routines for r1 except that now plant becomes G(s)/s 
[KiC, wC, SignAtInf] = utPIDGetR1Continuous(Model*ss(0,1,1,0),'pi',PlotNeeded);

%% but we return imag{1/G(jw)}*j instead of imag{1/G(jw)}*w as zpkR0Func
[f A B C D E IsModelProper] = utComputeRealImagInverseG(Model, 'imag');
[zz,pp,kk] = zpkdata(f,'v');
if IsModelProper
    zpkR0Func = zpk(pp,zz,0.5/kk);
else
    zpkR0Func = zpk(zz,pp,0.5*kk);
end
