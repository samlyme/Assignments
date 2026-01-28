import math

def is_prime(num):
    # Numbers less than 2 are not prime
    if num < 2:
        return False
    # 2 is the only even prime number
    if num == 2:
        return True
    # Even numbers greater than 2 are not prime
    if num % 2 == 0:
        return False
    
    # Check for divisibility from 3 up to the square root of the number,
    # incrementing by 2 to only check odd numbers
    for i in range(3, int(math.sqrt(num)) + 1, 2):
        if num % i == 0:
            return False
    return True

for n in range(100):
    if not is_prime(2*(n**2) + 29):
        print(n)
        break