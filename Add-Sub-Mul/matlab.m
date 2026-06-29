clc ;
close all ;
clear all ;

N = 240 ; % No of samples
f = 1e3 ;
fs = 48e3 ;
t = (0:N-1)/fs ;

x = 2 * sin(2 * pi * f * t) ;
total_len = 17 ;
frac_len = 14 ;
fixed = fi(x, 1, total_len, frac_len) ;

filename = 'files/op1_bin.txt' ;
file = fopen(filename, 'w') ;

fprintf(file, "// %d %d\n", total_len - frac_len, frac_len) ;
for k = 1:length(x)
    fprintf(file, "%s\n", bin(fixed(k))) ;
end

fprintf('Data generated for Q(%d, %d) and written into the file %s\n', total_len-frac_len, frac_len, filename) ;
