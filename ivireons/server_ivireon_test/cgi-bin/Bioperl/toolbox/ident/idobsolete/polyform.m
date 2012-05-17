function [a,b,c,d,f]=polyform(th)
%POLYFORM computes the polynomials associated with a given model
%   OBSOLETE function. Use POLYDATA instead.
%
%   [A,B,C,D,F]=polyform(TH)
%
%   TH is the model with format described by HELP THETA.
%
%   A,B,C,D, and F are returned as the corresponding polynomials
%   in the general input-output model. A, C and D are then row
%   vectors, while B and F have as many rows as there are inputs.

%   L. Ljung 10-1-86
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $ $Date: 2009/12/05 02:04:10 $

[a,b,c,d,f] = polydata(th,1);

