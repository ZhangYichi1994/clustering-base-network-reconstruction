function [ Accuarcy] = EvaluationFcn( C_hat,outer_mat)
%To test the accuracy of the reconstruction results

SIZE = size(outer_mat,1);
[m,n]= size(outer_mat);
epsi = 0.1;                                     %threshold

adjRecon = reshape(C_hat,m * n,1);         
adjReal  = reshape(outer_mat,m * n,1);    

for i = 1:size(adjRecon)
    if ( abs(adjRecon(i)-1 ) <= epsi)
        adjRecon(i) = 1;
    elseif ( abs(adjRecon(i)-0 ) <= epsi)
            adjRecon(i) = 0;
    end
end

% Calculate Accuarcy
acc = 0;
tp = 0;
for i = 1:size(adjReal)
    if (adjReal(i) == adjRecon(i))
        acc = acc +1;
    end
end
tp  = size(adjReal,1);
Accuarcy = acc/tp;

end