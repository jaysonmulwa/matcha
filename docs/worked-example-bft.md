# Worked example — Byzantine fault tolerance

A companion to the Redis grid in the [README](../README.md). The Redis example shows
the whole grid at once; this one walks a single concept **down** the ladder, so you can
see the exact `/matcha` commands that drive the progression.

Byzantine fault tolerance is a good test case: it has a number welded to a qualifier
(the `3f+1` bound) and a teaching analogy (the Byzantine generals) that must be flagged
low and suppressed high.

**Source facts** — every rendering may draw on these; none may exceed them:

- keeps a distributed system correct when some parts fail *arbitrarily*, including
  sending conflicting or false messages
- named after the Byzantine Generals Problem
- reaches agreement only while faulty parts stay below a threshold
- the bound: tolerates `f` faults with `n ≥ 3f+1` total — more than two-thirds honest
- used in blockchains and safety-critical systems like flight control

---

Start strict, then walk it down.

```
/matcha set expert
```
> Level set to **expert**. Applies from now on.

**You ask:** *explain Byzantine fault tolerance*

> BFT: consensus under arbitrary node behavior, not just crash-stop. Safety holds for
> `f` faulty of `n ≥ 3f+1` (the PBFT bound). Contrast Raft/Paxos, which assume
> `n ≥ 2f+1` and no lying. Used for blockchain finality and flight control.

```
/matcha rewrite plain
```
> Byzantine fault tolerance lets a distributed system agree even when some nodes fail
> arbitrarily — crashing, or sending conflicting information. It tolerates up to `f` bad
> nodes given at least `3f+1` total, i.e. over two-thirds honest. It underpins
> blockchains and safety-critical systems.

```
/matcha rewrite basic
```
> Byzantine fault tolerance keeps a system working when some parts fail or lie. Think of
> generals who must agree while some send false orders. *(That's an analogy, not the
> real thing.)* The honest parts still reach one decision — as long as more than
> two-thirds stay honest.
>
> **Couldn't simplify:** the exact rule `n ≥ 3f+1` and the names PBFT / Raft / Paxos —
> these are precise terms, kept as-is rather than rounded into something false.

---

Same facts throughout. Going down the ladder: the generals analogy appears only at
`basic` and is flagged as an analogy; `n ≥ 3f+1` survives as a formula until `basic`,
where it can't render and is named as held-back rather than faked into "most parts"
(which would be wrong — the bound is *two-thirds*, not half).
