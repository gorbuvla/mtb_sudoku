% ---------------------------------------------- 
% GENERATOR
%  generates a new game, see generator for 
%                           futher details
% ---------------------------------------------- 
function m = generator()
    
    % initial matrix for futher manipulations (solved game000.mat)
    init_mat = [6     5     8     1     9     7     4     3     2; ...
                3     7     4     8     2     6     1     5     9; ...
                2     1     9     3     5     4     8     6     7; ...
                5     2     7     4     1     3     6     9     8; ...
                8     4     6     5     7     9     2     1     3; ...
                9     3     1     6     8     2     7     4     5; ...
                4     8     5     2     3     1     9     7     6; ...
                1     9     3     7     6     8     5     2     4; ...
                7     6     2     9     4     5     3     8     1];
            
     m = shuffle(init_mat); %randomly shuffle matrix
     lst = 1:81;            %list of all non zero elements in m
     lst = lst(randperm(length(lst))); % random permutation of lst
     c = randi([20 40], 1, 1);         % c-> randomly pick how many non zero values should be
     lst = lst(1:length(lst)-c);       % get first c elements
 
     
     % while lst not empty
     %  delete first element
     %  try to solve
     %  if multiple solutions or impossible to solve -> put value back
     %  otherwise continue
     while ~isempty(lst)
         pos = lst(1);
         lst=lst(2:end);
         value = m(pos);
         m(pos) = 0;
         [imp, mto, ~] = slvr(m);
         if mto || imp
             m(pos) = value;
         end
     end  
end

function Mat = shuffle(mat)
    Mat = shuffrc(mat);
    Mat = shuffrc(Mat')';
    Mat = turn90(Mat);
    Mat = mirror(Mat);
end

function Mat = shuffrc(mat)
    ind = [1 4 7];
    max_sh = 3;
    min_sh = 1;
    t = randi([min_sh max_sh], 1, 1); % how many times to shuffle
    sh_r = randperm(3, t);                   % waht to shuffle   
    Mat = mat;
    
    for i = 1:length(sh_r)
        k = ind(sh_r(i));
        p = ind(randperm(3, 1));
        tmp = Mat(k:k+2, :);
        Mat(k:k+2, :) = Mat(p:p+2, :);
        Mat(p:p+2, :) = tmp;
    end
end

function Mat = turn90(mat)
    max_turn = 3;
    Mat = mat;
    t = randi([0 max_turn], 1, 1);
    while t ~= 0
       Mat = Mat';
       t = t - 1;
    end
end

function Mat = mirror(mat)
    Mat = mat;
    r = rand(1, 1);
    if r < 0.5
        Mat = fliplr(Mat);
    end
end