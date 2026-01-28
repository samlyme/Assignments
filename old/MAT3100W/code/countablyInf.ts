function* N(): Generator<number> {
  let i = 0;
  while (true) yield i++;
}

function* Z(): Generator<number> {
  yield 0;
  let i = 1;
  while (true) {
    yield i;
    yield -i;
    i++;
  }
}

function* forwardReplay<T>(g: Generator<T>): Generator<T> {
  const seen: T[] = [];
  for (const elem of g) {
    seen.push(elem);
    yield* seen;
  }
}

function* reverseReplay<T>(g: Generator<T>): Generator<T> {
  const seen: T[] = [];
  for (const elem of g) {
    seen.push(elem);
    yield* [...seen].reverse();
  }
}

export function* zipIter<T, U>(
  a: Generator<T>,
  b: Generator<U>
): Generator<[T, U]> {
  while (true) {
    const ra = a.next();
    const rb = b.next();
    if (ra.done || rb.done) break;
    yield [ra.value, rb.value];
  }
}

export function* cartesianProduct<T, R>(
  a: Generator<T>,
  b: Generator<R>
): IterableIterator<[T, R]> {
  yield* zipIter(forwardReplay(a), reverseReplay(b));
}

type Tree<T> = T | [Tree<T>, Tree<T>];

function* setPower<T>(it: () => Generator<T>, pow: number): Generator<Tree<T>> {
  if (pow <= 0) return;

  if (pow == 1) yield* it();

  if (pow % 2 == 0) {
    yield* cartesianProduct(setPower(it, pow / 2), setPower(it, pow / 2));
  } else {
    yield* cartesianProduct(it(), setPower(it, pow - 1));
  }
}

function flattenTree<T>(tree: Tree<T>): T[] {
  // Slightly more performant than the GPT result!
  function* trav(curr: Tree<T>): Generator<T> {
    if (!Array.isArray(curr)) {
      yield curr;
    } else {
      const [left, right] = curr;
      yield* trav(left);
      yield* trav(right);
    }
  }

  return [...trav(tree)];
}

const N3 = setPower(N, 5);

for (let i = 0; i < 101; i++) {
  const res: IteratorResult<Tree<number>> = N3.next();
  console.log(flattenTree(res.value));
}
