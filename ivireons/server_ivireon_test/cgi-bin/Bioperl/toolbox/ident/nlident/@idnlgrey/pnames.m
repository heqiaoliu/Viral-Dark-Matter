function [props, asgnvals] = pnames(varargin)
%PNAMES  Returns all public IDNLGREY object properties, and optionally their
%   their assignable values.
%
%   [PROPS, ASGNVALS] = PNAMES(NLSYS);
%
%   PROPS is the list of public properties (a cell vector) of an IDNLGREY
%   object. If PNAMES is called with two arguments it also returns a
%   list of assignable values ASGNVALS (a cell vector).
%
%   PROPS contains the true case-sensitive property names. These include
%   the public properties of the parent (IDNLMODEL) of the IDNLGREY object.
%
%   PROPS = PNAMES(NLSYS, 'specific') returns only the public IDNLGREY-
%   specific properties of NLSYS, wirhout those of the parent object.
%
%   PROPS = PNAMES(NLSYS, 'readonly') returns the read-only properties of
%   IDNLGREY (i.e., EstimationInfo).
%
%   See also IDNLMODEL/GET, IDNLMODEL/SET, IDNLGREY/PVGET, IDNLGREY/PVSET.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $ $Date: 2008/10/02 18:53:57 $
%   Written by Peter Lindskog.

% Check that the function is called with one or two arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));
nout = nargout;

% Determine what to compute.
specificflag = false;
readonlyflag = false;
if (nin > 1)
    if ischar(varargin{2})
        if strmatch(lower(varargin{2}), 'specific')
            specificflag = true;
        elseif strmatch(lower(varargin{2}), 'readonly')
            specificflag = true;
            readonlyflag = true;
        else
            ctrlMsgUtils.error('Ident:general:wrongPnamesFlag2')
        end
    end
end

% Check that NLSYS is an IDNLGREY object.
if ~isa(varargin{1}, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','pnames','IDNLGREY')
end

% IDNLGREY specific properties.
props = {'FileName';           ...
    'Order';              ...
    'Parameters';         ...
    'InitialStates';      ...
    'FileArgument';       ...
    'CovarianceMatrix';   ...
    'Algorithm';          ...
    'EstimationInfo'      ...
    };
if readonlyflag
    props = props(end);
end

% Assignable IDNLGREY values.
if (nout > 1)
    asgnvals = {['Chars (name of file defining the structure)'                         ... % FileName.
        ' or function handle'];                                               ...
        'Struct with fields nx, ny, nu';                                       ... % Order.
        'Npo-by-1 struct array of parameters';                                 ... % Parameters.
        'Nx-by-1 struct array of initial states';                              ... % InitialStates.
        'Optional argument passed to FileName';                                ... % FileArgument.
        '''None'', ''Estimate'' (user-assignable) or Np-by-Np matrix or []';   ... % CovarianceMatrix.
        'Struct with algorithm settings';                                      ... % Algorithm.
        'Structure containing estimation information (read-only property)'     ... % EstimationInfo.
        };
    if readonlyflag
        asgnvals = asgnvals(end);
    end
end

% Return the property names.
if ~(specificflag)
    % If called with one input, then return all public properties of an
    % IDNLGREY object, including the ones inherited from the parent.
    [propsparent, asgnvalsparent, top, bottom] = pnames(varargin{1}.idnlmodel);
    props = [propsparent(top); props(1:6); propsparent(bottom(1)); ...
        props(7:end); propsparent(bottom(2:end))];
    if (nout > 1)
        asgnvals = [asgnvalsparent(top); asgnvals(1:6); asgnvalsparent(bottom(1)); ...
            asgnvals(7:end); asgnvalsparent(bottom(2:end))];
    end
end