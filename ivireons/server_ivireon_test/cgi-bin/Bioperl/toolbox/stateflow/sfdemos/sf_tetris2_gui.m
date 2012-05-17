function sf_tetris2_gui(varargin)

%   Copyright 2006-2008 The MathWorks, Inc.
    
    ARENA_HEIGHT = 20;
    ARENA_WIDTH = 10;
    SHAPE_WIDTH = 4;
    persistent arenaImage waitShapeImage arenaAxis waitAxis statusAxis scoreText tetrisFig
    
    switch varargin{1}
        case 'close'
            if ~isempty(tetrisFig) && ishandle(tetrisFig) && strcmp(get(tetrisFig, 'Tag'), 'StateflowTetrisFigure')
                close(tetrisFig);
            end
            
        case 'init'
            if isempty(tetrisFig) || ~ishandle(tetrisFig) || ~strcmp(get(tetrisFig, 'Tag'), 'StateflowTetrisFigure')
           
                tetrisFig = figure('Name', 'Tetris', ...
                    'DoubleBuffer', 'on', ...
                    'KeyPressFcn', [mfilename, ' keypress'], ...
                    'Tag', 'StateflowTetrisFigure');

                arenaAxis = axes;
                arenaImage = image(zeros(ARENA_HEIGHT+1,ARENA_WIDTH+2), 'EraseMode', 'xor');
                waitAxis = axes;
                waitShapeImage = image(zeros(SHAPE_WIDTH,SHAPE_WIDTH), 'Parent', waitAxis, 'EraseMode', 'xor');
                statusAxis = axes;
                scoreText = text(0.5, 0.5, ...
                    sprintf('Score: 0\nLevel: 1\nLines: 0'), ...
                    'FontSize', 12, 'EraseMode', 'xor');
                
                helpAx = axes;
                set(helpAx, 'Position', [0.6, 0.7, 0.4/2.5, 0.4/2.5], ...
                    'DrawMode', 'fast', ...
                    'Visible', 'off');
                text(0.5,0.5, ...
                    sprintf('''p'' for pause/play\n''q'' for quit'));
            end
            
            figure(tetrisFig);

            set(arenaAxis, 'position', [0.1, 0.1, 0.4, 0.8], ...
                'DataAspectRatio', [1,1,1], ...
                'XTick', [], 'YTick', [], ...
                'DrawMode', 'fast', ...
                'YDir', 'normal');
            
            set(waitAxis, 'position', [0.6, 0.5, 0.4/2.5, 0.4/2.5], ...
                'DataAspectRatio', [1,1,1], ...
                'XTick', [], 'YTick', [], ...
                'DrawMode', 'fast', ...
                'YDir', 'normal');
            
            set(statusAxis, 'position', [0.6, 0.1, 0.4/2.5, 0.4/2.5], ...], ...
                'DrawMode', 'fast', ...
                'Visible', 'off');
            
            
        case 'draw'
            arena = varargin{2};
            shape = varargin{3};
            waitShape = varargin{4};
            px = varargin{5};
            py = varargin{6};
            score = varargin{7};
            level = varargin{8};
            lines = varargin{9};
            
            for i=1:SHAPE_WIDTH
                for j=1:SHAPE_WIDTH
                    if (px+i >= 1 && px+i <= 12 && py+j > 1 && py+j <= 21 && shape(j,i) > 0)
                        arena(py+j,px+i) = shape(j,i);
                    end
                end
            end
            set(arenaImage, 'CData', arena*8);
            
            set(waitShapeImage, 'CData', waitShape*8);
            set(scoreText, 'String', ...
                sprintf('Score %d\nLevel: %d\nLines: %d', score, level, lines));
            pause(0.01);
            
        case 'keypress'
            ch = double(get(gcbf, 'CurrentCharacter'));
            switch ch
                case {28, double('j')}
                    triggerBlock = 'Left';
                case {29, double('l')}
                    triggerBlock = 'Right';
                case {30, double('i')}
                    triggerBlock = 'RotC';
                case {31, double('k')}
                    triggerBlock = 'RotAC';
                case double(' ')
                    triggerBlock = 'Drop';
                case {double('z')}
                    triggerBlock = 'Down';
                case {double('p')}
                    pauseOrContinue;
                    return;
                case {double('q')}
                    quitGame;
                    return;
                otherwise
                    return;
            end
            nm = ['sf_tetris2/' triggerBlock];
            prevVal = str2double(get_param(nm, 'Value'));
            dirty = get_param('sf_tetris2', 'dirty');
            set_param(nm, 'value', num2str(prevVal+1));
            set_param('sf_tetris2', 'dirty', dirty);
    end
    
function pauseOrContinue
    
    status = get_param('sf_tetris2', 'SimulationStatus');
    switch status
        case 'running'
            set_param('sf_tetris2', 'SimulationCommand', 'pause');
        case 'paused'
            set_param('sf_tetris2', 'SimulationCommand', 'continue');
        case 'stopped'
            set_param('sf_tetris2', 'SimulationCommand', 'start');
    end
    
    
function quitGame
    set_param('sf_tetris2', 'SimulationCommand', 'stop');
    
