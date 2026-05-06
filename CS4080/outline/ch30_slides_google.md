# Chapter 30: Optimization

Performance work in `clox`: measuring, profiling, hash table probing, and NaN boxing.

# The Big Idea

- Optimization starts from a working program.
- The goal is better resource use without changing behavior.
- Speed is common, but resources also include memory, startup time, storage, and bandwidth.
- Modern hardware makes performance hard to predict from intuition alone.
- Central lesson: optimize empirically.

# An Empirical Workflow

1. Choose the resource that matters.
2. Use benchmarks to define the workload.
3. Use profilers to find where time or memory goes.
4. Make a targeted change.
5. Re-measure to verify the effect.

# Benchmarks

- Benchmarks are performance tests.
- They show whether an optimization helped.
- They show whether an unrelated change caused a regression.
- A benchmark suite is better than a single benchmark.
- Benchmarks are proxies for the real goal: faster user programs.

# Benchmark Design Risks

- A benchmark can accidentally measure the wrong thing.
- Microbenchmarks may overfit to one implementation detail.
- Results can be noisy because of caching, scheduling, CPU throttling, and OS behavior.
- Benchmark suites age as language ecosystems and workloads change.

# Profiling

- A profiler runs the VM while collecting resource-use data.
- In this chapter, the profiled program is `clox` running a Lox script.
- Simple profilers show time by function.
- Advanced profilers can show cache misses, branch misses, allocations, and other hardware metrics.

# Optimization 1

Faster hash table probing with bit masks.

# Why Hash Tables Matter

- Dynamic-language operations often depend on hash lookup.
- Important paths include global variable access, field reads, method calls, and method invocation.
- These paths converge on `tableGet()` and `findEntry()`.

# The Hotspot

- `run()` has the largest inclusive time because it is the bytecode loop.
- Expensive instructions include `OP_GET_GLOBAL`, `OP_GET_PROPERTY`, and `OP_INVOKE`.
- Profiling shows their real shared cost: hash table lookup.
- Before the change, `tableGet()` takes roughly 72% of total benchmark time.

# Slow Key Wrapping

- The original table lookup computes `index = hash % capacity`.
- `%` wraps a hash into the valid table index range.
- Modulo and division are much slower than addition, subtraction, and bitwise operations on typical CPUs.
- The profiler identifies this as the unexpectedly expensive line.

# Power-of-Two Capacity

- `clox` table capacities are always powers of two.
- For powers of two, `hash % capacity` equals `hash & (capacity - 1)`.
- `capacity - 1` creates a mask for the valid lower bits.
- The change applies to initial lookup and probe wraparound.
- It also applies to `tableFindString()` for string interning.

# Performance Effect

- Before bit masking: about 3,192 fixed-time benchmark batches.
- After bit masking: about 6,249 fixed-time benchmark batches.
- The benchmark is nearly 2x faster.
- Afterward, `tableGet()` drops from about 72% to about 35% of total time.

# Hash Table Takeaways

- The code change is tiny, but the hotspot is huge.
- The win depends on a real invariant: capacities are powers of two.
- Profiling helps both find the target and confirm the fix.
- The lesson is not to remove every modulo.
- The lesson is to measure first, then optimize the line that matters.

# Optimization 2

NaN boxing for a smaller `Value` representation.

# Why Rethink `Value`?

- Original representation: type tag plus union payload.
- On 64-bit machines, the original `Value` is about 16 bytes.
- Goal: store each value in 8 bytes.
- Smaller values improve memory density.
- Better memory density can reduce cache misses.

# The Dynamic Language Problem

- Runtime values must carry enough information to identify their type.
- Lox numbers are C `double` values, which already use 64 bits.
- The challenge is to store numbers, Booleans, `nil`, and object pointers in one 64-bit representation.
- NaN boxing uses unused IEEE 754 NaN bit patterns for non-number values.

# IEEE 754 Opportunity

- A double has 52 fraction bits, 11 exponent bits, and 1 sign bit.
- When all exponent bits are set, the value is special.
- Many quiet-NaN bit patterns are available.
- `clox` reserves some of those patterns to encode non-number Lox values.

# NaN-Boxed Values

- Numbers use their raw 64-bit `double` bits.
- `nil` uses reserved quiet-NaN bits plus a small tag.
- Booleans use reserved quiet-NaN bits plus `true` or `false` tags.
- Objects use the sign bit, quiet-NaN bits, and pointer bits.
- Normal numbers do not need wrapping into a separate object.

# Conditional Support

- NaN boxing depends on low-level floating-point and pointer assumptions.
- `clox` keeps both the original tagged union and the NaN-boxed `uint64_t` representation.
- A compile-time flag, `NAN_BOXING`, selects the representation.
- Most VM code stays stable because it already uses value macros.

# Numbers

- A Lox number is already a C `double`.
- The implementation needs to reinterpret the same bits as either `double` or `uint64_t Value`.
- Helper functions use `memcpy()` for type punning.
- Compilers usually optimize this pattern away.
- `NUMBER_VAL`, `AS_NUMBER`, and `IS_NUMBER` hide the representation details.

# `nil`, `true`, and `false`

- Singleton values need only one unique bit pattern each.
- `TAG_NIL`, `TAG_FALSE`, and `TAG_TRUE` distinguish them.
- Each singleton combines reserved quiet-NaN bits with a small tag.
- `BOOL_VAL`, `AS_BOOL`, and `IS_BOOL` preserve the existing macro interface.

# Objects

- Object values must encode pointer addresses.
- The implementation uses the sign bit as an object marker.
- Object values also include reserved quiet-NaN bits and low pointer bits.
- `OBJ_VAL` boxes the pointer.
- `AS_OBJ` masks away marker bits to recover it.
- `IS_OBJ` checks both sign and quiet-NaN bits.

# Value Functions

- Most code remains behind macros.
- `printValue()` tests Boolean, nil, number, then object.
- `valuesEqual()` can compare raw bits for most values.
- Numbers need special equality handling because IEEE 754 NaN is not equal to itself.

# Evaluating NaN Boxing

- The benefit is diffuse rather than one obvious hotspot.
- Expected wins: smaller values, better cache behavior, and fewer cache misses.
- Possible costs: extra bitwise operations and more complicated type checks.
- Larger benchmarks show roughly 10% speed improvement.

# Where To Next?

The implementation is complete, but language work can keep going.

# Future Directions

- Add compile-time optimization passes.
- Add static typing.
- Study parser theory, type systems, semantics, and formal logic.
- Turn Lox into a personal language experiment.
- Build documentation, examples, libraries, and tools for real users.

# End-of-Chapter Challenges

- Profile the VM with multiple benchmarks and look for new hotspots.
- Implement inline storage for small strings.
- Write relevant benchmarks to evaluate small-string performance.
- Reflect on what learning approaches worked best throughout the book.

# Optimization Summary

- Table index wrapping changes from `% capacity` to `& (capacity - 1)`.
- String lookup uses the same bit-mask wrapping idea.
- Value representation changes from a 16-byte tagged union to an 8-byte NaN-boxed value.
- Equality becomes a number-aware bit comparison.
- The main benefits are faster probing and better cache behavior.

# Study Questions

1. Why is profiling more reliable than guessing?
2. When can a benchmark measure the wrong thing?
3. Why does `% capacity` become `& (capacity - 1)` only for powers of two?
4. Why can smaller values make a VM faster?
5. What portability risks come with NaN boxing?

# Key Takeaway

Optimization is not cleverness first. It is measurement, evidence, and carefully tested changes.
