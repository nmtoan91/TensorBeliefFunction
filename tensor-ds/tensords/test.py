def generate_combinations(elements):
    n = len(elements)
    result = []
    # Generate all combinations using bit manipulation
    for i in range(1, 2**n):
        combo = []
        for j in range(n):
            if i & (1 << j):
                combo.append(elements[j])
        result.append(''.join(combo))
    
    # Sort the result by the length of each combination, then lexicographically
    result.sort(key=lambda x: (len(x), x))
    return result

# Example usage
elements = ['a', 'b', 'c', 'd']
combinations = generate_combinations(elements)
print(combinations)