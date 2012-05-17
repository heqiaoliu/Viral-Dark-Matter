function x = cfint(value, issigned, wordlength, rmode, omode)
%CFINT  C-style fi integer.
%   cfint(VALUE) returns a C-style fi integer 
%   cfint(VALUE, SIGNED) 
%   cfint(VALUE, SIGNED, WORDLENGTH) 
%   cfint(VALUE, SIGNED, WORDLENGTH, ROUNDMODE) 
%   cfint(VALUE, SIGNED, WORDLENGTH, ROUNDMODE, OVERFLOWMODE) 
%
%   Defaults: 
%   SIGNED = true 
%   WORDLENGTH = 16 
%   ROUNDMODE = 'floor' 
%   OVERFLOWMODE = 'wrap'
%
%   Examples:
%     fipref('LoggingMode','On')
%     warning on fi:overflow
%     warning off backtrace
%
%     a = cfint(32767);
%     b = a + 1
%     % Returns -32768
%
%     c = cfint(255, false, 8);
%     d = c + 1
%     % Returns 0
%
%   See also FI, SFI, UFI, FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, FIXEDPOINT.

%   Thomas A. Bryan, 5 April 2005
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/03 14:28:44 $

error(nargchk(1,5,nargin,'struct'))

if nargin<2, issigned   = []; end
if nargin<3, wordlength = []; end
if nargin<4, rmode      = ''; end
if nargin<5, omode      = ''; end

if isempty(issigned),   issigned   = true;    end
if isempty(wordlength), wordlength = 16;      end
if isempty(rmode),      rmode      = 'floor'; end
if isempty(omode),      omode      = 'wrap';  end

x=fi(value,issigned,wordlength,0,... 
     'roundmode',rmode,... 
     'overflow',omode,... 
     'productmode','specify',... 
     'productwordlength',wordlength,... 
     'productfractionlength',0,... 
     'summode','specify',... 
     'sumwordlength',wordlength,... 
     'sumfractionlength',0);

