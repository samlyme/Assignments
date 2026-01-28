print("a b | a OR b")
print("------------")

for a in [True, False]:
    for b in [True, False]:
        print(f"{'T' if a else 'F'} {'T' if b else 'F'} | {'T' if a or b else 'F'}")
# a b | a OR b
# ------------
# T T | T
# T F | T
# F T | T
# F F | F

# This function assumes the order of our input -> [(F,F,F), (F,F,T), (F,T,F), ...(T,T,T)]
def func(desired_output: list[bool]) -> str:
    if len(desired_output) != 8:
        return ""

    out = "False" # quick and dirty 

    for index, output in enumerate(desired_output):
        if not output:
            continue

        out += f" or ({'' if (index // 4) % 2 == 0 else '!'}P and {'' if (index // 2) % 2 == 0 else '!'}Q and {'' if index % 2 == 0 else '!'}R)"

    return out


print(func([True] * 8))
# False or (P and Q and R) or (P and Q and !R) or (P and !Q and R) or (P and !Q and !R) or (!P and Q and R) or (!P and Q and !R) or (!P and !Q and R) or (!P and !Q and !R)

print(func([False] * 8))
# False

print(func([n % 2 == 0 for n in range(8)]))
# False or (P and Q and R) or (P and !Q and R) or (!P and Q and R) or (!P and !Q and R)