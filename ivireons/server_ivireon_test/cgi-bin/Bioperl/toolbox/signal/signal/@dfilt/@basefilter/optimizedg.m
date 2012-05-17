function DG = optimizedg(Hd,hTar,DG)
%OPTIMIZEDG Optimize directed graph of filter HD
%   Optimize directed graph for gain1, gain0, gainN1, delay chain and
%   coverter chain

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 16:07:32 $

checkoptimizable(Hd, hTar); 

check_if_optimizezeros_possible(Hd,hTar);

HdArithmetic = get_arith(Hd);
optimize(DG,strcmpi(hTar.OptimizeOnes,'on'),...
    strcmpi(hTar.OptimizeNegOnes,'on'),...
    strcmpi(hTar.OptimizeZeros,'on'),...
    strcmpi(hTar.OptimizeDelayChains,'on'),...
    strcmpi(hTar.MapCoeffsToPorts,'on'),...
    HdArithmetic);

% Garbage Collection (clean up)
DG = gc(DG);

% [EOF]
