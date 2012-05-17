function cbs = callbacks(this)
%CALLBACKS Callbacks for the Pole/Zero Editor

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2005/02/23 02:55:18 $

cbs              = siggui_cbs(this);
cbs.gain         = @gain_cb;
cbs.scale        = @scale_cb;
cbs.rotate       = @rotate_cb;
cbs.currentvalue = @currentvalue_cb;
cbs.keypress     = @keypress_cb;
cbs.currentsection = @currentsection_cb;

% -----------------------------------------------------
function currentsection_cb(hcbo, eventStruct, this)

set(this, 'CurrentSection', str2num(popupstr(hcbo)));

% -----------------------------------------------------
function currentvalue_cb(hcbo, eventStruct, this)

cv = getcurrentvalue(this);

if strcmpi(get(hcbo, 'tag'), 'real'),
    one = evaluatevars(get(hcbo, 'String'));
    if strcmpi(this.CoordinateMode, 'polar'),
        two = angle(cv);
    else
        two = imag(cv);
    end
else
    two = evaluatevars(get(hcbo, 'String'));
    if strcmpi(this.CoordinateMode, 'polar'),
        one = abs(cv);
    else
        one = real(cv);
    end
end

% Convert to rectangular coordinates.
if strcmpi(this.CoordinateMode, 'polar'),
    cv = one*(sin(two)*i+cos(two));
else
    cv = one+two*i;
end

setcurrentvalue(this, cv);

% -----------------------------------------------------
function gain_cb(hcbo, eventStruct, this)

gain   = evaluatevars(fixup_uiedit(hcbo));
set(this, 'Gain', gain{1});

% -----------------------------------------------------
function scale_cb(hcbo, eventStruct, this)

type = getcurrenttype(this);

scalefactor = inputdlg(sprintf('Scale %s by factor:', type), sprintf('Scale %s', type), 1, {'1'});

if ~isempty(scalefactor),

    try,
        
        scalefactor = evaluatevars(scalefactor{1});

        scale(this, scalefactor);
    catch
        senderror(this, 'Invalid scale factor.');
    end
end

% -----------------------------------------------------
function rotate_cb(hcbo, eventStruct, this)

type = getcurrenttype(this);

rotatefactor = inputdlg(['Rotate ' type ' by radians:'], ['Rotate ' type], 1, {'1'});

if ~isempty(rotatefactor),


    try,
        
        rotatefactor = evaluatevars(rotatefactor{1});

        rotate(this, rotatefactor);
    catch
        senderror(this, 'Invalid rotation factor.');
    end
end

% -----------------------------------------------------
function keypress_cb(hFig, eventStruct, this)

if isempty(getcurrenttype(this)) || isempty(get(hFig, 'CurrentCharacter')), return; end

switch abs(get(hFig, 'CurrentCharacter'))
    case 28 % left arrow
        this.setcurrentvalue(getcurrentvalue(this) - .1);
    case 29 % right arrow
        this.setcurrentvalue(getcurrentvalue(this) + .1);
    case 30 % up arrow
        this.setcurrentvalue(getcurrentvalue(this) + .1i);
    case 31 % down arrow
        this.setcurrentvalue(getcurrentvalue(this) - .1i);
    case {8, 127} % backspace and delete
        deletecurrentroots(this);
end

currentroots_listener(this, 'update_currentvalue');

% [EOF]
