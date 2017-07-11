% ---------------------------------------------- 
% UI STATE
%   change buttons appearence
% ---------------------------------------------- 
function ui_state(next_state, gameObject)
    switch next_state
        case 'init'
            set(gameObject.btn_solve, 'Enable', 'off');
            set(gameObject.btn_save, 'Enable', 'off');
        case 'post_load'
            set(gameObject.btn_solve, 'Enable', 'on');
            set(gameObject.btn_save, 'Enable', 'on');
    end
end

