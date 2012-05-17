function [GF_TABLE1 GF_TABLE2] = populateTables(h, m) %#ok<INUSL>
% POPULATETABLES - Create GF tables for user-defined primitive polynomials
%
%   This function requires m, the exponent of the extension field.  It uses code
%   that is also used in gftable.m.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/30 23:24:26 $

global GF_TABLE_PRIM_POLY

x = gf(0:2^m-1,m, GF_TABLE_PRIM_POLY)';

% Turn off the gftable warning about lookup tables not being defined for
% nondefault primitive polynomials, since the purpose of this function is to
% create nondefault tables.
warnState = warning('off','comm:gftablewarning');
x1 = x(3).^(0:2^m-2);
warning(warnState);

% Create indices corresponding to the integer values of x1.  For example, if
% m=3 and prim_poly=13, then ind = [1 2 4 5 7 3 6].
ind = double(x1.x);

% Create a vector corresponding to the exponential representation of the field
% elements.  For example, if m=3 and prim_poly=13, then x = [0 1 5 2 3 6 4].
[notUsed, x] = sort(ind);
x = x - 1;

table = [[ind'; 1] [-1; x']];
GF_TABLE1 = uint32(table(2:end,1));
GF_TABLE2 = uint32(table(2:end,2));

%[EOF]