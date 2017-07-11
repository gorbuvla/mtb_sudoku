% ---------------------------------------------- 
% CALLBACK HANDLERS, HELPER FUNCTIONS
% ---------------------------------------------- 
function matrix_util(func, gameObject)
    switch func
        case 'click_s'
            click_s(gameObject);
        case 'click_b'
            click_b(gameObject);
        case 'load'
            load_m(gameObject);
        case 'save'
            save_m(gameObject);
        case 'gen'
            gen_game(gameObject);
        case 'solve'
            solve(gameObject);
        %case 'clear'
        %    clear_axes(gameObject);
    end

end

% ---------------------------------------------- 
% LOAD GAME FILE
% file should be a .mat file containing:
%       sudoku_matrix variable -> game matrix
%       stde variable -> indicates which cells
%                        are not editable
% ---------------------------------------------- 
function load_m(gameObject)
    [filename, filepath] = uigetfile('*.mat', 'Select .mat file');
    if filename > 0
        abs_path = fullfile(filepath, filename);
        m_struct = load(abs_path);
        clear_axes(gameObject);        %clear axes before loading new game
        game_config = populate(gameObject, m_struct);   %load
        set(gameObject.axes, 'UserData', game_config);   
    end
end

% ---------------------------------------------- 
% SAVE GAME FILE
%   saves game into a .mat file
% ---------------------------------------------- 
function save_m(gameObject)
    data = get(gameObject.axes, 'UserData');
        if ~isempty(data) 
            [filename, pathname] = uiputfile('*.mat', 'Save Current Game');
            if filename > 0
                sudoku_matrix = data.matrix;
                stde = data.stde;
                save(fullfile(pathname, filename), 'sudoku_matrix', 'stde');
            end  
        end
end

% ---------------------------------------------- 
% GENERATE NEW GAME
%   see generator.m for more details on game gen
% ---------------------------------------------- 
function gen_game(gameObject)
    %generate & prepare structure for loading into ui
    str.sudoku_matrix = generator();
    str.stde = zeros(9, 9);
    st = str.sudoku_matrix > 0;
    str.stde(st)=1;
    
    %load generated game
    clear_axes(gameObject);
    game_config = populate(gameObject, str);
    set(gameObject.axes, 'UserData', game_config);
end


% ---------------------------------------------- 
% SOLVE GAME
%   solves currently displayed game in ui
%   for more details on solving see slvr.m
% ---------------------------------------------- 
function solve(gameObject)
    data = get(gameObject.axes, 'UserData');
    
    % imposs -- impossible to solve
    % mto -- More Than One (solution)
    % RES -- first found result
    [imposs, mto, RES] = slvr(data.matrix);
    
    if imposs
        warndlg('Current game configuration has no solution.');
        return;
    elseif mto
        warndlg('Inconsistent puzzle. Multiple solutions found.');
    end
    str.sudoku_matrix = RES;
    str.stde = data.stde;
    clear_axes(gameObject);
    game_config = populate(gameObject, str);
    set(gameObject.axes, 'UserData', game_config);
end

% ---------------------------------------------- 
% SMALL BTN OnCLICK HANDLER
%   invoked once user selects one of 9 possible
%   assingments for a cell
%   alters candidates array of adjacent 
%               cells/row/col/etc
% ---------------------------------------------- 
function click_s(gameObject)
    
    data = get(gameObject.axes, 'UserData');
    btn_pos = get(gcbo, 'Position');
    col = fix(btn_pos(1) + 1);
    row = 9 - fix(btn_pos(2)); 
    value = str2double(get(gcbo, 'String'));
    
    switch get(gcbf, 'SelectionType')
        case 'normal'
            data.matrix(row, col) = value;
            data.adjacency{row, col}(value) = 0;
            % turn on big btn with chosen value
            data.squares_filled(row, col) = get_b(col-0.5, 9.5-row, value, 'blue');
            
            % turn off visibility of clicked btn value in adjacent row/col
            for i = 1:9
                if ~data.stde(row, i)
                    data.adjacency{row, i}(value) = 0;
                    set(data.squares_free(row, i, value), 'Visible', 'off');
                end
                
                if ~data.stde(i, col)
                    data.adjacency{i, col}(value) = 0;
                    set(data.squares_free(i, col, value), 'Visible', 'off');
                end
            end
        
            [r_s, c_s] = get_subm_ind(row, col);
            % turn off visibility of clicked btn value in current 3x3 box
            for r = r_s:(r_s+2)
               for c = c_s:(c_s+2)
                   if ~data.stde(r, c)
                      data.adjacency{r, c}(value) = 0;
                      set(data.squares_free(r, c, value), 'Visible', 'off');
                   end    
               end
            end
            
            %turn off small btns in clicked cell
            for k = 1:9
                set(data.squares_free(row, col, k), 'Visible', 'off');
            end
    end
    set(gameObject.axes, 'UserData', data);
end

% ---------------------------------------------- 
% BIG BTN OnCLICK HANDLER
%   invoked once user wants to alter game matrix
%
%   sets back candidates to adjacent 
%               cells/row/col/etc
% ---------------------------------------------- 
function click_b(gameObject)
     data = get(gameObject.axes, 'UserData');
     btn_pos = get(gcbo, 'Position');
     col = fix(btn_pos(1) + 1);
     row = 9 - fix(btn_pos(2));
     value = str2double(get(gcbo, 'String'));
     
     switch get(gcbf, 'SelectionType')
         
         case 'normal'
             data.matrix(row, col) = 0;
             data.adjacency{row, col}(value) = 1;
             delete(data.squares_filled(row, col));
             data.squares_filled(row, col) = 0;
             
             % turn on visibility for small buttons in row/col
             for c = 1:9
                 if ~is_cell_adj_to_val(data.matrix, row, c, value) && ~data.stde(row, c)
                    data.adjacency{row, c}(value)=1;
                    if data.matrix(row, c) == 0
                        set(data.squares_free(row, c, value), 'Visible', 'on');
                    end
                 end
                 if ~is_cell_adj_to_val(data.matrix, c, col, value) && ~data.stde(c, col)
                    data.adjacency{c, col}(value)=1;
                    if data.matrix(c, col) == 0
                        set(data.squares_free(c, col, value), 'Visible', 'on');
                    end
                 end
             end
             
             [r_s, c_s] = get_subm_ind(row, col);
             
             % turn on visibility for small buttons in current 3x3 box
             for i = r_s:r_s+2
                for j = c_s:c_s+2
                    if ~data.stde(i, j) && ~is_cell_adj_to_val(data.matrix, i, j, value)
                       data.adjacency{i, j}(value) = 1;
                       if data.matrix(i, j) == 0
                          set(data.squares_free(i, j, value), 'Visible', 'on'); 
                       end
                    end
                end
             end
             
             % turn on visivility for small buttons in clicked cell
             for i = 1:9
                 
                 if data.adjacency{row, col}(i)
                    set(data.squares_free(row, col, i), 'Visible', 'on');
                 end
                 
             end
     end
     set(gameObject.axes, 'UserData', data);
end

% ---------------------------------------------- 
% CLEAR AXES
%   clears axes before new game loaded
% ---------------------------------------------- 
function clear_axes(gameObject)
    userData = get(gameObject.axes, 'UserData');
    if ~isempty(userData)
        delete(userData.squares_filled(userData.squares_filled > 0));
        delete(userData.squares_free(userData.squares_free > 0));
    end
end

% ---------------------------------------------- 
% POPULATE GAME
%   creates structures nessessary for future game
%   displays loaded matrix in ui
%
%   data.matrix -> game matrix with currently
%                       chosen values
%   data.adjacency -> cell array of candidates
%   data.stde -> indicates values(in data.matrix)
%                   that cannot be changed
%   data.squres_filled -> matrix of ui texts
%                          for data.matrix
%   data.squares_free -> 3dim matrix of ui texts
%                          for data.adjacency
% ---------------------------------------------- 
function r = populate(gameObject, game_config)

    adj = adjacency(game_config.sudoku_matrix, game_config.stde);
    squares_filled = zeros(9, 9);
    squares_free = zeros(9, 9, 9);
    % x & y positions for small buttons in cell
    x = [0.8 0.5 0.2 0.8 0.5 0.2 0.8 0.5 0.2]; 
    y = [0.2 0.2 0.2 0.5 0.5 0.5 0.8 0.8 0.8];
    
    axes(gameObject.axes);
    
    for i1 = 1:9
        for i2 = 1:9
            if game_config.sudoku_matrix(i1, i2) ~= 0
                if game_config.stde(i1, i2) 
                    squares_filled(i1, i2) = get_b(i2-0.5, 9.5-i1, game_config.sudoku_matrix(i1, i2), 'green');                                            
                else
                    squares_filled(i1, i2) = get_b(i2-0.5, 9.5-i1, game_config.sudoku_matrix(i1, i2), 'blue');
                    for i3 = 1:9
                        squares_free(i1, i2, i3) = get_s(i2 - x(i3), 9 - i1 + y(i3), num2str(i3), 'off');
                    end
                end      
            else
                for i3 = 1:9
                    if adj{i1, i2}(i3) ~= 0
                        squares_free(i1, i2, i3) = get_s(i2 - x(i3), 9 - i1 + y(i3), num2str(i3), 'on');
                    else
                        squares_free(i1, i2, i3) = get_s(i2 - x(i3), 9 - i1 + y(i3), num2str(i3), 'off');
                    end
                end
            end
        end
    end

r.matrix = game_config.sudoku_matrix;
r.adjacency = adj;
r.stde = game_config.stde;
r.squares_filled = squares_filled;
r.squares_free = squares_free;
end

% ---------------------------------------------- 
% GET BIG BUTTON
% ---------------------------------------------- 
function r = get_b(x_pos, y_pos, value, color)
    switch color
        case 'green'
            r = text(x_pos, y_pos, num2str(value),...
                                     'FontSize', 36, ...
                                     'Color', [46/256 139/256 87/256], ...
                                     'HorizontalAlignment', 'center'); 
        case 'blue'
            r = text(x_pos, y_pos, num2str(value),...
                                     'FontSize', 36, ...
                                     'Color', [0 0 205/256], ...
                                     'ButtonDownFcn', 'game_callback(''action_click_b'', get(gcbf, ''UserData''));', ...
                                     'HorizontalAlignment', 'center');
    end
end

% ---------------------------------------------- 
% GET SMALL BUTTON
% ---------------------------------------------- 
function r = get_s(x_pos, y_pos, value, visible)
    r = text(x_pos, y_pos, value, ...
               'FontSize', 8, ...
               'HorizontalAlignment', 'center', ...
               'Visible', visible, ...
               'ButtonDownFcn', 'game_callback(''action_click_s'', get(gcbf, ''UserData''));');
end

% ---------------------------------------------- 
% ADJACENCY
%   find candidates for each cell
% ---------------------------------------------- 
function adj = adjacency(matrix, stde)
    adj = cell(9, 9);
    for ind1 = 1:9
        for ind2 = 1:9
            if (~stde(ind1, ind2))
                adj{ind1, ind2} = adj_cell(matrix, ind1, ind2);
            end
        end 
    end
end

% ---------------------------------------------- 
% ADJACENCY
%   find candidates for single cell
% ---------------------------------------------- 
function map = adj_cell(matrix, r, c)
    row = matrix(r, :);
    col = matrix(:, c);
    sub_m = get_submatrix(matrix, r, c);
    map = ones(9, 1);
    for v = 1:9
        if (sum(any(sub_m == v))>0 || sum(any(row==v) + any(col==v))>0)
            map(v) = 0;
        end
    end
end

% ---------------------------------------------- 
% ADJACENCY
%   ckeck if value may be a candidate for 
%           a certain cell
% ---------------------------------------------- 
function bool = is_cell_adj_to_val(matrix, r, c, value)
    row = matrix(r, :);
    col = matrix(:, c);
    sub_m = get_submatrix(matrix, r, c);
    bool = 0;
    if (sum(any(sub_m == value))>0 || sum(any(row==value) + any(col==value))>0)
        bool = 1;
    end
end


function [r_s, c_s] = get_subm_ind(r, c)
    r_s = 3*fix((r-1)/3)+1;
    c_s = 3*fix((c-1)/3)+1;
end

function sub_m = get_submatrix(matrix, r, c)
    r_s = 3*fix((r-1)/3)+1;
    c_s = 3*fix((c-1)/3)+1;
    sub_m = matrix(r_s:r_s+2, c_s:c_s+2);
end


