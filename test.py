import time
import math
import random
import statistics


def benchmark(name, func, repeat=5):
    """Run a function multiple times and print timing stats."""
    times = []
    for _ in range(repeat):
        start = time.perf_counter()
        func()
        end = time.perf_counter()
        times.append(end - start)

    print(f"=== {name} ===")
    print(f"  runs : {repeat}")
    print(f"  min  : {min(times):.4f} s")
    print(f"  max  : {max(times):.4f} s")
    print(f"  avg  : {statistics.mean(times):.4f} s")
    print()


# ---- heavier tasks to test CPU / memory performance ----

def cpu_heavy():
    # Many math operations (CPU bound)
    total = 0.0
    # increased from ~100k to 1,000,000 iterations
    for i in range(1_000_000):
        total += math.sqrt(i) * math.sin(i)
    return total


def sort_heavy():
    # Larger list sort (memory + CPU)
    # increased from 500k to 1,000,000 elements
    data = [random.random() for _ in range(1_000_000)]
    data.sort()
    return data[0]


def loop_heavy():
    # Simple integer operations, more iterations
    # increased from 5,000,000 to 20,000,000
    s = 0
    for i in range(20_000_000):
        s += i % 7
    return s


if __name__ == "__main__":
    random.seed(0)  # keep runs more comparable

    print("Running heavier benchmarks...\n")
    benchmark("CPU-heavy math", cpu_heavy, repeat=5)
    benchmark("List sort", sort_heavy, repeat=5)
    benchmark("Integer loop", loop_heavy, repeat=5)

    print("Run this same script on both Macs (in the same kind of venv) and compare the times.")