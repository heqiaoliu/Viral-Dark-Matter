%FIXPTMASKINIT may be called by Fixed-Point Blocks with broken links.
%    
%   FIXPTMASKINIT is a private function used by previous versions of 
%   Fixed-Point Blockset.  If it is being called, the likely cause is that
%   links to Fixed-Point blocks were broken.  These links need to be restored
%   for the model to work properly.  This can be done automatically using
%   SLUPDATE.
%
%    See also SLUPDATE.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  
% $Date: 2005/06/24 11:11:31 $

dispstr = sprintf('ERROR\nBROKEN\nLINK');

xFixptSymbol = [];
yFixptSymbol = [];

error([ sprintf( [ '\n'...
        'An obsolete function from the Fixed-Point Blockset has been called.\n' ...
        'A Fixed-Point Block with a broken link is the likely cause.  See\n' ...
        'SLUPDATE for information on restoring the link.\n' ...
        'The current block is\n']) gcb ]);