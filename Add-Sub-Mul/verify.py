import numpy as np
import matplotlib.pyplot as plt
import os

DATA = "files"
FIGS = "figs"
WIDTH = 17

os.makedirs(FIGS, exist_ok=True)

def load_bin(name):
    with open(f"{DATA}/{name}.txt") as f:
        _, ib, fb = f.readline().split()
        fb = int(fb)
        bits = f.read().split()

    ints = np.array([int(b, 2) - (1 << WIDTH) if b[0] == '1' else int(b, 2) for b in bits])

    return ints / (2 ** fb), fb


def load_verilog(name, fb):
    ints = np.loadtxt(f"{DATA}/{name}_outputs.txt", dtype=int)
    if name == 'mul' :
        return ints / (4 * (2 ** fb))
    else :
        return ints / (2 ** fb)
    

def plot(op, ref, ver):
    err = np.abs(ver - ref)
    mae = np.mean(err)

    print(f"{op.upper()} | MAE = {mae:.3e}")

    plt.figure(figsize=(10, 8))

    plt.subplot(3, 1, 1)
    plt.plot(ref)
    plt.title("Python Reference")

    plt.subplot(3, 1, 2)
    plt.plot(ver)
    plt.title("Verilog Output")

    plt.subplot(3, 1, 3)
    plt.plot(err)
    plt.title(f"Absolute Error (MAE={mae:.2e})")

    plt.tight_layout()
    plt.savefig(f"{FIGS}/{op}.png")
    plt.close()


op1, fb1 = load_bin("op1_bin")
op2, fb2 = load_bin("op2_bin")

results = {
    "add": (op1 + op2, max(fb1, fb2)),
    "sub": (op1 - op2, max(fb1, fb2)),
    "mul": (op1 * op2, fb1 + fb2),
    "mul_eff" : (op1 * op2/(2 ** 14), fb1 + fb2),
}

print("-" * 30)
print("Mean Absolute Error")
print("-" * 30)

for name, (ref, fb) in results.items():
    ver = load_verilog(name, fb)
    plot(name, ref, ver)

print("-" * 30)
print(f"Plots saved in '{FIGS}/'")
