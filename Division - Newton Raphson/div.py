import math

def init_guess(d, mode) :
    if mode == 0 :
        return 4*(math.sqrt(3)-1) - 2*d
    elif mode == 1 :
        return (1/99) * (256 * d * d - 576 * d + 420)
    else :
        return (48 - 32*d)/17

def division_by_reciprocation(frac, mode, iter_lim) :
    n = frac[0]
    d = frac[1]
    m = d
    shift = 0
    while m >= 1 :
        m /= 2
        shift += 1
    while m < 0.5 :
        m *= 2 
        shift -= 1
    
    x = init_guess(m, mode)
    # Newton-Raphson iterations
    err = float('inf')
    iter_count = 0
    while err > 1e-6 and iter_count <= iter_lim :
        x_next = x * ( 2 - x * m)
        err = abs(x_next - x)
        x = x_next
        iter_count += 1
    return (n * (x_next / 2 ** shift)), iter_count

def ans(frac) :
    ans_orig = frac[0]/frac[1]
    ans1, iter_count1 = division_by_reciprocation(frac, 0, 2)
    err_linear = abs(ans1 - ans_orig)
    ans2, iter_count2 = division_by_reciprocation(frac, 1, 2)
    err_quad = abs(ans2 - ans_orig)
    ans3, iter_count3 = division_by_reciprocation(frac, 2, 2)
    err_frac = abs(ans3 - ans_orig)
    print(f'Test {frac[0]}/{frac[1]} : After 2 iterations')
    print('Division by reciprocation using linear initial guess :\nAns = ', ans3, 'Original Ans = ', ans_orig, 'Error = ', err_frac)
    print('Division by reciprocation using linear initial guess ( b = 2 ):\nAns = ', ans1, 'Original Ans = ', ans_orig, 'Error = ', err_linear)
    print('Division by reciprocation using quadratic initial guess :\nAns = ', ans2, 'Original Ans = ', ans_orig, 'Error = ', err_quad)
    print()

'''
iter_lim = 1
frac = (15, 23)
n, d = frac[0], frac[1]
ans_orig = n / d
'''

frac_list = [(15, 23), (10, 79), (142, 51), (17, 64), (100, 127), (1, 255)]
for elem in frac_list :
    ans(elem)

'''
ans1, iter_count1 = division_by_reciprocation(frac, 0, 1)
err_linear = abs(ans1 - ans_orig)
ans2, iter_count2 = division_by_reciprocation(frac, 1, 1)
err_quad = abs(ans2 - ans_orig)
ans3, iter_count3 = division_by_reciprocation(frac, 2, 1)
err_frac = abs(ans3 - ans_orig)
print('After 1 iteration')
print('Division by reciprocation using linear initial guess :\nAns = ', ans3, 'Original Ans = ', ans_orig, 'Error = ', err_frac)
print('Division by reciprocation using linear initial guess ( b = 2 ):\nAns = ', ans1, 'Original Ans = ', ans_orig, 'Error = ', err_linear)
print('Division by reciprocation using quadratic initial guess :\nAns = ', ans2, 'Original Ans = ', ans_orig, 'Error = ', err_quad)
print()

ans1, iter_count1 = division_by_reciprocation(frac, 0, 2)
err_linear = abs(ans1 - ans_orig)
ans2, iter_count2 = division_by_reciprocation(frac, 1, 2)
err_quad = abs(ans2 - ans_orig)
ans3, iter_count3 = division_by_reciprocation(frac, 2, 2)
err_frac = abs(ans3 - ans_orig)
print('After 2 iterations')
print('Division by reciprocation using linear initial guess :\nAns = ', ans3, 'Original Ans = ', ans_orig, 'Error = ', err_frac)
print('Division by reciprocation using linear initial guess ( b = 2 ):\nAns = ', ans1, 'Original Ans = ', ans_orig, 'Error = ', err_linear)
print('Division by reciprocation using quadratic initial guess :\nAns = ', ans2, 'Original Ans = ', ans_orig, 'Error = ', err_quad)
print()

ans1, iter_count1 = division_by_reciprocation(frac, 0, 3)
err_linear = abs(ans1 - ans_orig)
ans2, iter_count2 = division_by_reciprocation(frac, 1, 3)
err_quad = abs(ans2 - ans_orig)
ans3, iter_count3 = division_by_reciprocation(frac, 2, 3)
err_frac = abs(ans3 - ans_orig)
print('After 3 iterations')
print('Division by reciprocation using linear initial guess :\nAns = ', ans3, 'Original Ans = ', ans_orig, 'Error = ', err_frac)
print('Division by reciprocation using linear initial guess ( b = 2 ):\nAns = ', ans1, 'Original Ans = ', ans_orig, 'Error = ', err_linear)
print('Division by reciprocation using quadratic initial guess :\nAns = ', ans2, 'Original Ans = ', ans_orig, 'Error = ', err_quad)
print()
'''