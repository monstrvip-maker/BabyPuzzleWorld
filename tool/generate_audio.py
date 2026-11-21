import math, os, struct, wave

os.makedirs("assets/audio", exist_ok=True)

def make(name, notes, duration, volume=0.22):
    rate = 22050
    count = int(rate * duration)
    with wave.open(f"assets/audio/{name}.wav", "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        data = bytearray()
        for i in range(count):
            t = i / rate
            fade = min(1.0, i / (rate * 0.012), (count - i) / (rate * 0.04))
            sample = sum(math.sin(2 * math.pi * hz * t) for hz in notes) / len(notes)
            data.extend(struct.pack("<h", int(32767 * volume * max(0, fade) * sample)))
        out.writeframes(data)

make("tap", [660], 0.09, 0.18)
make("correct", [523, 659, 784], 0.28)
make("win", [523, 659, 784, 1047], 0.52, 0.24)
