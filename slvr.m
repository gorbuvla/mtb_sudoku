function [imposs, mto, RES] = slvr(matrix)
      [~, imposs, mto, RES] = slv(matrix, false, []);
end


% ---------------------------------------------- 
% SOLVES PUZZLES 
%   using natural cell/row/col/box reduction
%       (i.e. there might be only one possible 
%       assignment for 1 in a row)
%   and guessing
%   once solution is found, solver continues till
%   there is no solution or finds second and sets
%   mto = true (used in puzzle generator)
%   
%   M - matrix
%   imposs - impossible to solve
%   mto - More Than One (solution)
%   RES - first found solution
% ---------------------------------------------- 
function [M, imposs, mto, RES] = slv(M, mto, RES)
    if mto
        imposs = 1;
        return
    end
    
    [M, imposs] = reduce(M);
    
    if imposs
       return;
    end
    
    z = find(M == 0);
    if isempty(z)
        %display('solved');
        if isempty(RES)
           RES = M;
        else
            mto = true;
        end
        return;
    end
    
    impossall=zeros(1, 9);
    % recursive quess
    for i = 1:9
        Q=M;
        Q(z(1))=i;
        [Q, impossall(i), mto, RES]=slv(Q, mto, RES);
    end
    
    imposs=all(impossall);
    M=Q;
end


function [M, imposs] = reduce(M)

    imposs = 0;
    Mprev = M+1;
    while any(M-Mprev)
        Mprev=M;
        
        %get candidates
        N=ones(9, 9, 9);
        [r, c] = find(M ~= 0);
        for n = 1:length(r)
            N(r(n), c(n), :)=0;
            N(r(n), c(n), M(r(n), c(n)))=1;
        end
        
        % if there are cells with no option -> return
        if any(any(sum(N, 3)<1))
           imposs = 1;
           return
        end
        
        [r, c] = find(sum(N, 3) == 1);
        for n = 1:length(r)
            
            % if there are cells with no option -> return
            if any(any(sum(N, 3)<1))
                imposs = 1;
                return
            end
            
            v = find(N(r(n), c(n), :));
            M(r(n), c(n)) = v; % set value
            N(:, c(n), v) = 0; % delete from row
            N(r(n), :, v) = 0; % delete from col 
            
            [r_s, c_s] = get_subm_ind(r(n), c(n));
            
            N(r_s:r_s+2, c_s:c_s+2, v)=0; % delete in 3x3 box 
            N(r(n), c(n), v) = 1;         
        end
        
    % find cells with only one option
    for r=1:9
        for c=1:9
            v=find(N(r,c,:));
            if length(v)==1
                M(r,c)=v;
            end
        end
    end
    
    % find rows with only one option 
    for r=1:9
        for v=1:9
            c=find(N(r,:,v));
            if length(c)==1
                M(r,c)=v;
            end
        end
    end
    
    % find column with only one option
    for c=1:9
        for v=1:9
            r=find(N(:,c,v));
            if length(r)==1
                M(r,c)=v;
            end
        end
    end
    
    % find 3x3 box with only one option
    for r=[1 4 7]
        for c=[1 4 7]
            for v=1:9
                Q=N(r:r+2,c:c+2,v);
                [pr,pc]=find(Q);
                if length(pr)==1
                    M(r+pr-1,c+pc-1)=v;
                end
            end
        end
    end
    end
end

function [r_s, c_s] = get_subm_ind(r, c)
    r_s = 3*fix((r-1)/3)+1;
    c_s = 3*fix((c-1)/3)+1;
end

