from math import lcm


def get_distinct_sums(target, start=1):
    # Base case: if target is 0, we found a valid combination
    if target == 0:
        return [[]]
    
    results = []
    
    # Iterate from 'start' to the target
    for i in range(start, target + 1):
        # Recursively find combinations for the remaining value
        # We pass 'i + 1' to ensure the next number is strictly greater (distinct)
        sub_combinations = get_distinct_sums(target - i, i + 1)
        
        for combo in sub_combinations:
            results.append([i] + combo)
            
    return results

def orders(n):
    sizes = set()

    for i in range(1, n+1):
        for j in get_distinct_sums(i):
            sizes.add(lcm(*j))

    out = list(sizes)
    out.sort()
    return out

print(orders(10))