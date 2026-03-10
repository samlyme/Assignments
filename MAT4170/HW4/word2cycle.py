word = [0,1,5,6,2,4,3] # prepend with a zero for convenience.

def word_to_cycle(word):
    explored = set()
    def explore(i):
        out = []
        while i not in explored:
            explored.add(i)
            out.append(i)
            i = word[i]
        return out

    out = [explore(i) for i in word]
    return list(filter(lambda x: len(x) > 1, out))

    
print(word_to_cycle(word)) # [[5, 4, 2], [6, 3]]

word1 = [0,6,2,1,4,3,5]
print(word, word1)

def compose_word(a, b):
    out = [0] * max(len(a), len(b))
    
    for i in range(1, len(out)):
        out[i] = b[a[i]] if a[i] < len(b) else a[i]

    return out

print(compose_word(word, word1)) # [0, 6, 3, 5, 2, 4, 1]

def cycle_to_word(cycles):
    n = 1 + max(max(cycle) for cycle in cycles)
    word = list(range(n))

    for cycle in cycles:
        for x, y in zip(cycle, cycle[1:] + [cycle[0]]):
            word[x] = y

    return word

print(cycle_to_word(word_to_cycle(word))) #[0,1,5,6,2,4,3]
        
def compose_cycle(a, b):
    x = cycle_to_word(a)
    y = cycle_to_word(b)
    return word_to_cycle(compose_word(x, y))

p1 = [[2,5,4],[3, 6]] 
p2 = [[4,5], [1,2]]
print(compose_cycle(p1, p2)) #[0, 2, 4, 6, 1, 5, 3]

def order_cycle(cycles):
    curr = cycles
    i = 1

    while len(curr) > 0:
        i += 1
        curr = compose_cycle(cycles, curr)

    return i

def order_word(word):
    curr = word 
    i = 1
    while not all(index == x for (index, x) in enumerate(curr)):
        i += 1
        curr = compose_word(word, curr)

    return i

print(order_cycle(p1))
print(order_word(cycle_to_word(p1)))
    