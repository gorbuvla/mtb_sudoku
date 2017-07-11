% ---------------------------------------------- 
% REDIRECT UI CALLBACKS TO APPROPRIATE FUNCTIONS
% ---------------------------------------------- 
function game_callback(action, gameObject)
    switch action
        case 'action_load'
            matrix_util('load', gameObject);
            ui_state('post_load', gameObject);
        case 'action_save'
            matrix_util('save', gameObject);
        case 'action_click_s'
            matrix_util('click_s', gameObject);
        case 'action_click_b'
            matrix_util('click_b', gameObject);
        case 'action_gen'
            matrix_util('gen', gameObject);
            ui_state('post_load', gameObject);
        case 'action_solve'
            matrix_util('solve', gameObject);
    end
end
