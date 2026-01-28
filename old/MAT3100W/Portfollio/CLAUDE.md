# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a LaTeX-based academic portfolio for MAT 3100W (Introduction to Proofs). The main document (`portfolio.tex`) contains mathematical proofs and explanations of fundamental mathematical concepts including logic, set theory, number systems, relations, functions, and various proof techniques.

## Build System

### Compiling the Document

The portfolio is a LaTeX document that needs to be compiled to generate the PDF output:

```bash
# Compile the portfolio (requires pdflatex)
pdflatex portfolio.tex

# For proper cross-references and citations, run twice:
pdflatex portfolio.tex && pdflatex portfolio.tex
```

### Output Files

- `portfolio.pdf` - The compiled PDF document (tracked in git)
- `portfolio.synctex.gz` - SyncTeX file for editor-PDF synchronization
- `portfolio.aux`, `portfolio.log` - LaTeX auxiliary files (not tracked)

## Project Structure

```
Portfollio/
├── portfolio.tex          # Main LaTeX source document
├── portfolio.pdf          # Compiled PDF output
├── images/               # Venn diagrams and visual aids
│   ├── default-sets-venn.png
│   ├── AuB-venn.png      # Union visualization
│   ├── AnU-venn.png      # Intersection visualization
│   ├── AmB-venn.png      # Set difference visualization
│   └── Ac-venn.png       # Complement visualization
└── CLAUDE.md            # This file
```

## Document Architecture

The portfolio is organized into three main sections:

### 1. Mathematical Concepts (Section 2)

Foundational concepts that build upon each other:

- **Logic and DeMorgan's Laws** (2.1): Logical statements, connectives, truth tables, and DeMorgan's Laws
- **Sets** (2.2): Set operations (union, intersection, complement, difference), DeMorgan's Laws for sets, and Venn diagrams
- **Numbers and Number Systems** (2.3): Parity, divisibility, modular arithmetic, rational/irrational numbers, combinatorics, countable/uncountable sets
- **Relations and Functions** (2.4): Relations, equivalence relations, functions, injections, surjections, bijections

### 2. Proof Techniques (Section 3)

Each subsection demonstrates a specific proof method with examples:

- **Direct Proofs** (3.1): Using fundamental logical rules and axioms
- **Transformation of Conditionals** (3.2): Contrapositive, converse, inverse, and bidirectional proofs
- **Quantifiers** (3.3): Universal and existential quantifiers, multiply quantified statements
- **Existence and Uniqueness** (3.4): Proving both existence and uniqueness properties
- **Induction** (3.5): Mathematical induction with base cases and inductive steps
- **Contradiction** (3.6): Proof by contradiction (including √2 irrationality and Cantor's diagonalization)

### 3. Supporting Sections

- **Introduction** (Section 1): Overview of mathematical concepts and proof techniques
- **Final Project** (Section 4): Placeholder section
- **Conclusion and Reflection** (Section 5): Personal reflection on the course
- **Appendix**: Course objectives and learning outcomes

## LaTeX Packages and Conventions

### Key Packages Used

- `mathtools`, `amsfonts`, `amsthm` - Mathematical typesetting
- `hyperref` - Hyperlinked cross-references
- `cleveref` - Smart cross-referencing (use `\cref{}` for automatic reference types)
- `todonotes` - TODO annotations
- `multicol` - Multi-column layouts (used in Venn diagram section)
- `graphicx` - Image inclusion

### Theorem Environments

The document defines several theorem-style environments:

- `theorem` - For major theorems
- `lemma` - For supporting lemmas
- `proposition` - For propositions
- `definition` - For formal definitions
- `example` - For examples with proofs

### Cross-Referencing

The document uses extensive cross-referencing via `\label{}` and `\cref{}`:

- Labels follow the pattern: `{type}:{descriptive-name}`
  - Example: `\label{prop:modular-arithmetic1}`, `\label{lemma:bijection-cardinality}`
- Use `\cref{label}` for automatic reference formatting (e.g., "Lemma 1", "Theorem 2")

## Mathematical Notation Conventions

- Number sets: `\mathbb{N}` (naturals), `\mathbb{Z}` (integers), `\mathbb{Q}` (rationals), `\mathbb{R}` (reals)
- Set operations: `\cup` (union), `\cap` (intersection), `\setminus` (difference), `^c` (complement)
- Logical connectives: `\lor` (or), `\land` (and), `\neg` (not), `\rightarrow` (implies)
- Relations: `\in` (element of), `\subset` (subset), `\equiv` (congruent), `\pmod{}` (modulo)
- Functions: `f: A \rightarrow B` for function notation

## Git Workflow

This repository is part of a larger assignments repository (`Assignments-F2025`):

- Remote: `git@github.com:samlyme/Assignments-F2025.git`
- Main branch: `main`
- The PDF and synctex files are tracked in git (intentional for this academic project)

## Working with Images

All visual aids are PNG files in the `images/` directory. These are primarily Venn diagrams illustrating:

- Basic set relationships (A, B, universal set)
- Union (`AuB-venn.png`)
- Intersection (`AnU-venn.png`)
- Set difference (`AmB-venn.png`)
- Complement (`Ac-venn.png`)

When adding new images, reference them with: `\includegraphics[width=.3\textwidth]{./images/filename.png}`

## Common Tasks

### Adding a New Proof

1. Identify the appropriate section based on the proof technique
2. Use the relevant theorem environment (`\begin{theorem}...\end{theorem}`)
3. Add a `\label{}` for cross-referencing
4. Include the proof in `\begin{proof}...\end{proof}` environment
5. Recompile twice to update cross-references

### Adding Mathematical Definitions

1. Use `\begin{definition}...\end{definition}` environment
2. Add a descriptive label if the definition will be referenced elsewhere
3. Use proper mathematical notation with LaTeX commands

### Checking Cross-References

If you modify labels or add new theorems/lemmas, compile twice to ensure all `\cref{}` references update correctly.
