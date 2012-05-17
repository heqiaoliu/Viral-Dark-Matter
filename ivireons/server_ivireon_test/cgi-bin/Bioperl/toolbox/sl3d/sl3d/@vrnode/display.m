function display(N)
%DISPLAY Display a VRNODE array.
%   DISPLAY(N) displays a VRNODE array in a standard format.
%   This method is called when the semicolon is not used with
%   a statement that results in such an array.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:34 $ $Author: batserve $


% take 'compact' into account
lfnolf = char([10 0]);
lf = lfnolf(isequal(get(0, 'FormatSpacing'), 'compact')+1);

% print variable name
fprintf('%c%s = \n%c', lf, inputname(1), lf);

% print variable dimension
sz = size(N);
fprintf('\tvrnode object: %s%d\n%c', sprintf('%d-by-', sz(1:end-1)), sz(end), lf);

% call DISP to print variable values
disp(N);

% print final linefeed if necessary
fprintf('%c', lf);
