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


# Gentle original instrumental loop for the children's game.
def make_background():
    rate = 22050
    duration = 16.0
    count = int(rate * duration)
    melody = [
        (0.0, 659.25), (1.0, 783.99), (2.0, 880.00), (3.0, 783.99),
        (4.0, 698.46), (5.0, 783.99), (6.0, 659.25), (7.0, 587.33),
        (8.0, 523.25), (9.0, 659.25), (10.0, 783.99), (11.0, 659.25),
        (12.0, 587.33), (13.0, 659.25), (14.0, 523.25), (15.0, 587.33),
    ]
    chords = [
        (0.0, 261.63, 329.63, 392.00),
        (4.0, 220.00, 261.63, 329.63),
        (8.0, 174.61, 220.00, 261.63),
        (12.0, 196.00, 246.94, 293.66),
    ]
    def bell(t, start, hz):
        x = t - start
        if x < 0 or x >= 0.92:
            return 0.0
        env = min(1.0, x / 0.035) * math.exp(-3.3 * x)
        return math.sin(2 * math.pi * hz * x) * env
    with wave.open("assets/audio/background.wav", "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        data = bytearray()
        for i in range(count):
            t = i / rate
            pad = 0.0
            for start, a, b, c in chords:
                if start <= t < start + 4.0:
                    local = t - start
                    fade = min(1.0, local / 0.25, (4.0 - local) / 0.25)
                    pad = fade * (0.10 * math.sin(2*math.pi*a*t) +
                                  0.075 * math.sin(2*math.pi*b*t) +
                                  0.06 * math.sin(2*math.pi*c*t))
                    break
            tune = sum(0.20 * bell(t, start, hz) for start, hz in melody)
            # A soft high note gives the loop a playful, nursery-like feel.
            sparkle = 0.025 * math.sin(2 * math.pi * 1318.51 * t) * (0.5 + 0.5 * math.sin(2 * math.pi * 0.25 * t))
            edge = min(1.0, t / 0.18, (duration - t) / 0.18)
            sample = max(-0.8, min(0.8, (pad + tune + sparkle) * max(0.0, edge)))
            data.extend(struct.pack("<h", int(32767 * sample)))
        out.writeframes(data)

make_background()
