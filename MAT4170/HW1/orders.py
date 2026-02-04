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

s7_sizes = get_distinct_sums(7)
s7_max_order = max(lcm(*size) for size in s7_sizes)
print(s7_max_order)


s10_sizes = get_distinct_sums(10)
s10_max_order = max(lcm(*size) for size in s10_sizes)
print(s10_max_order)
