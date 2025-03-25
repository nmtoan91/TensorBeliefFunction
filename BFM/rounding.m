function roundedmat = rounding(mat, sigdigits)
% ROUNDING round number in MAT to a number of significant digits

multiplier = 10^sigdigits;
tmp_mat = round(mat.*multiplier);
roundedmat = tmp_mat./multiplier;
