%matlab -batch "my_test"
results = zeros(19, 1); % store execution times


for exp = 1:20
    len = 2^exp;
    tic;
    
    % Generate random vectors
    m1 = rand(len, 1);
    m2 = rand(len, 1);

    % Normalize vectors (sum to 1)
    m1 = m1 / sum(m1);
    m2 = m2 / sum(m2);

    % Apply DST function
    M_comb_PCR6 = DST([m1, m2], len);

    % Store elapsed time
    results(exp) = toc;

    fprintf('Length %d took %.4f seconds.\n', len, results(exp));
end


%results: 2:0.0333 4:0.0099  8:0.1636