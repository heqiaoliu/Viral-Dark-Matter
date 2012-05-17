%DESIGNMETHODS Return the available design methods for a filter designer.
%   M = DESIGNMETHODS(D) returns the available design methods for the
%   filter designer D and its current 'Specification'. 
%
%   M = DESIGNMETHODS(D, 'default') returns the default design method for
%   the filter designer D and its current 'Specification'. 
%
%   M = DESIGNMETHODS(D, TYPE) returns either FIR or IIR design methods
%   specified by the string 'fir' or 'iir'.  By default all design methods
%   are shown.
%
%   M = DESIGNMETHODS(D, 'full') returns the full name for each of the
%   available design methods, e.g. 'butter' will be 'Butterworth'.
%
%   % EXAMPLE #1 - Construct a lowpass filter designer and check its design methods.
%   d = fdesign.lowpass('N,Fc',10,12000,48000)
%   m = designmethods(d)
%
%   % EXAMPLE #2 - Change the specifications and check the updated methods.
%   d.Specification = 'Fp,Fst,Ap,Ast';
%   m2 = designmethods(d)
%   m3 = designmethods(d, 'iir')
%   m4 = designmethods(d, 'iir', 'full')
%
%   % EXAMPLE #3 - Get help on a particular method.
%   help(d, m2{1})
%
%   See also FDESIGN, FDESIGN/DESIGN, FDESIGN/DESIGNOPTS, FDESIGN/HELP.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/08/20 13:26:42 $


% [EOF]
