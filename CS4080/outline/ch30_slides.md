---
marp: true
theme: default
size: 16:9
paginate: true
footer: "CS4080 | Chapter 30"
style: |
  section {
    font-family: "Aptos", "Helvetica Neue", Arial, sans-serif;
    background: #f7f8fb;
    color: #17202a;
    padding: 54px 72px 50px;
  }
  section::after {
    color: #607080;
    font-size: 18px;
  }
  footer {
    color: #667381;
    font-size: 16px;
  }
  h1 {
    color: #0d3b66;
    font-size: 44px;
    margin-bottom: 22px;
  }
  h2 {
    color: #146c94;
    font-size: 30px;
    margin-top: 0;
  }
  p, li {
    font-size: 27px;
    line-height: 1.28;
  }
  ul, ol {
    padding-left: 1.1em;
  }
  strong {
    color: #7a3e00;
  }
  code {
    background: #e8edf3;
    border-radius: 5px;
    padding: 0.05em 0.22em;
    font-size: 0.82em;
  }
  table {
    font-size: 22px;
    width: 100%;
  }
  th {
    color: #0d3b66;
  }
  .small li, .small p {
    font-size: 23px;
  }
  .split {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 36px;
    align-items: start;
  }
  .callout {
    border-left: 8px solid #d1495b;
    padding-left: 24px;
    margin-top: 28px;
  }
  section.lead {
    display: flex;
    flex-direction: column;
    justify-content: center;
  }
  section.lead h1 {
    font-size: 58px;
    margin-bottom: 18px;
  }
  section.lead p {
    font-size: 32px;
    max-width: 900px;
  }
---

<!-- _class: lead -->

# Chapter 30: Optimization

Performance work in `clox`: measuring, profiling, hash table probing, and NaN boxing.

---

# The Big Idea

- Optimization starts from a **working program**.
- The goal is better resource use without changing behavior.
- Speed is common, but resources also include memory, startup time, storage, and bandwidth.
- Modern hardware makes performance hard to predict from intuition alone.

<div class="callout">

**Central lesson:** optimize empirically.

</div>

---

# An Empirical Workflow

1. Choose the resource that matters.
2. Use benchmarks to define the workload.
3. Use profilers to find where time or memory goes.
4. Make a targeted change.
5. Re-measure to verify the effect.

---

# Benchmarks

- Benchmarks are performance tests.
- They answer:
  - Did the optimization help?
  - Did another change create a regression?
- A suite is better than a single benchmark because different programs stress different paths.
- Benchmarks are proxies for the real goal: faster user programs.

---

# Benchmark Design Risks

- A benchmark can accidentally measure the wrong thing.
- Microbenchmarks may overfit to one implementation detail.
- Results can be noisy because of caching, scheduling, CPU throttling, and OS behavior.
- Benchmark suites age as language ecosystems and workloads change.

---

# Profiling

- A profiler runs the VM while collecting resource-use data.
- In this chapter, the profiled program is `clox` running a Lox script.
- Simple profilers show time by function.
- Advanced profilers can show cache misses, branch misses, allocations, and other hardware metrics.

---

<!-- _class: lead -->

# Optimization 1

Faster hash table probing with bit masks.

---

# Why Hash Tables Matter

- Dynamic-language operations often depend on hash lookup.
- In the benchmark, common operations include:
  - Global variable access.
  - Field reads.
  - Method calls.
  - Method invocation.
- These paths converge on `tableGet()` and `findEntry()`.

---

# The Hotspot

- `run()` has the largest inclusive time because it is the bytecode loop.
- Expensive instructions include:
  - `OP_GET_GLOBAL`
  - `OP_GET_PROPERTY`
  - `OP_INVOKE`
- Profiling shows their real shared cost: hash table lookup.
- Before the change, `tableGet()` takes roughly **72%** of total benchmark time.

---

# Slow Key Wrapping

- The original table lookup computes:

```c
index = hash % capacity;
```

- `%` wraps a hash into the valid table index range.
- Modulo and division are much slower than addition, subtraction, and bitwise operations on typical CPUs.
- The profiler identifies this as the unexpectedly expensive line.

---

# Power-of-Two Capacity

- `clox` table capacities are always powers of two.
- For powers of two:

```c
hash % capacity == hash & (capacity - 1)
```

- `capacity - 1` creates a mask for the valid lower bits.
- The change applies to initial lookup and probe wraparound.
- It also applies to `tableFindString()` for string interning.

---

# Performance Effect

| Version | Fixed-time benchmark result |
| --- | ---: |
| Before bit masking | about 3,192 batches |
| After bit masking | about 6,249 batches |

- The benchmark is nearly **2x faster**.
- Afterward, `tableGet()` drops from about **72%** to about **35%** of total time.

---

# Hash Table Takeaways

- The code change is tiny, but the hotspot is huge.
- The win depends on a real invariant: capacities are powers of two.
- Profiling helps both find the target and confirm the fix.
- The lesson is not "remove every modulo."
- The lesson is "measure first, then optimize the line that matters."

---

<!-- _class: lead -->

# Optimization 2

NaN boxing for a smaller `Value` representation.

---

# Why Rethink `Value`?

<div class="split">

<div>

## Original

- Type tag.
- Union payload.
- On 64-bit machines, about 16 bytes.

</div>

<div>

## Goal

- Store each value in 8 bytes.
- Improve memory density.
- Reduce cache misses.

</div>

</div>

---

# The Dynamic Language Problem

- Runtime values must carry enough information to identify their type.
- Lox numbers are C `double` values, which already use 64 bits.
- The challenge: store numbers, Booleans, `nil`, and object pointers in one 64-bit representation.
- NaN boxing uses unused IEEE 754 NaN bit patterns for non-number values.

---

# IEEE 754 Opportunity

- A double has:
  - 52 fraction bits.
  - 11 exponent bits.
  - 1 sign bit.
- When all exponent bits are set, the value is special.
- Many quiet-NaN bit patterns are available.
- `clox` reserves some of those patterns to encode non-number Lox values.

---

# NaN-Boxed Values

| Lox value kind | Representation idea |
| --- | --- |
| Number | Raw 64-bit `double` bits |
| `nil` | Reserved quiet-NaN bits plus small tag |
| Boolean | Reserved quiet-NaN bits plus `true` or `false` tag |
| Object | Sign bit plus quiet-NaN bits plus pointer bits |

Normal numbers do not need wrapping into a separate object.

---

# Conditional Support

- NaN boxing depends on low-level floating-point and pointer assumptions.
- `clox` keeps both representations:
  - Original tagged union.
  - NaN-boxed `uint64_t`.
- A compile-time flag, `NAN_BOXING`, selects the representation.
- Most VM code stays stable because it already uses value macros.

---

# Numbers

- A Lox number is already a C `double`.
- The implementation needs to reinterpret the same bits as either:
  - `double`
  - `uint64_t Value`
- Helper functions use `memcpy()` for type punning.
- Compilers usually optimize this pattern away.
- `NUMBER_VAL`, `AS_NUMBER`, and `IS_NUMBER` hide the representation details.

---

# `nil`, `true`, and `false`

- Singleton values need only one unique bit pattern each.
- `TAG_NIL`, `TAG_FALSE`, and `TAG_TRUE` distinguish them.
- Each singleton combines:
  - Reserved quiet-NaN bits.
  - A small tag.
- `BOOL_VAL`, `AS_BOOL`, and `IS_BOOL` preserve the existing macro interface.

---

# Objects

- Object values must encode pointer addresses.
- The implementation uses:
  - Sign bit as an object marker.
  - Reserved quiet-NaN bits.
  - Low pointer bits.
- `OBJ_VAL` boxes the pointer.
- `AS_OBJ` masks away marker bits to recover it.
- `IS_OBJ` checks both sign and quiet-NaN bits.

---

# Value Functions

- Most code remains behind macros.
- Representation-aware functions still change:
  - `printValue()` tests Boolean, nil, number, then object.
  - `valuesEqual()` can compare raw bits for most values.
- Numbers need special equality handling because IEEE 754 NaN is not equal to itself.

---

# Evaluating NaN Boxing

- The benefit is diffuse rather than one obvious hotspot.
- Expected wins:
  - Smaller values.
  - Better cache behavior.
  - Fewer cache misses.
- Possible costs:
  - Extra bitwise operations.
  - More complicated type checks.
- Larger benchmarks show roughly **10%** speed improvement.

---

<!-- _class: lead -->

# Where To Next?

The implementation is complete, but language work can keep going.

---

# Future Directions

- Add compile-time optimization passes.
- Add static typing.
- Study parser theory, type systems, semantics, and formal logic.
- Turn Lox into a personal language experiment.
- Build documentation, examples, libraries, and tools for real users.

---

# End-of-Chapter Challenges

- Profile the VM with multiple benchmarks and look for new hotspots.
- Implement inline storage for small strings.
- Write relevant benchmarks to evaluate small-string performance.
- Reflect on what learning approaches worked best throughout the book.

---

# Optimization Summary

| Area | Original | Optimized | Main benefit |
| --- | --- | --- | --- |
| Table index wrapping | `% capacity` | `& (capacity - 1)` | Faster probing |
| String lookup | Modulo wrapping | Bit-mask wrapping | Better interning path |
| Value representation | 16-byte tagged union | 8-byte NaN-boxed value | Better cache behavior |
| Equality | Type switch | Number-aware bit comparison | Works with boxed values |

---

# Study Questions

1. Why is profiling more reliable than guessing?
2. When can a benchmark measure the wrong thing?
3. Why does `% capacity` become `& (capacity - 1)` only for powers of two?
4. Why can smaller values make a VM faster?
5. What portability risks come with NaN boxing?

---

<!-- _class: lead -->

# Key Takeaway

Optimization is not cleverness first. It is measurement, evidence, and carefully tested changes.
