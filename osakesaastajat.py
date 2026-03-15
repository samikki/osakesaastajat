#!/usr/bin/env python3
"""
OSAKESAASTAJAT
Alkuperäinen: Sami K., 1984 (julkaistu Mikrobitti 3/1985)
Python-versio: 2026
"""

import sys
import random
import tty
import termios
import time

# --- ANSI / terminal ---
BLUE_BG = "\033[44m"
WHITE   = "\033[97m"
RESET   = "\033[0m"
CLR     = "\033[2J\033[H"
CUU     = "\033[A"   # cursor up one line
EL      = "\033[2K"  # erase line


def clr():
    sys.stdout.write(CLR)
    sys.stdout.flush()


def get_key():
    """Read one keypress without Enter — like BASIC's GET."""
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    return ch.upper()


def press_any_key():
    """Subroutine 1000: PAINA NAPPIA."""
    print("\nPAINA NAPPIA.")
    get_key()


def yn_prompt():
    """Wait for K or E keypress."""
    while True:
        k = get_key()
        if k in ("K", "E"):
            return k


def get_int(prompt):
    """Input an integer; erase line and retry on bad input."""
    while True:
        try:
            return int(input(prompt))
        except (ValueError, EOFError):
            sys.stdout.write(f"{CUU}{EL}")
            sys.stdout.flush()


# --- Subroutine 1100: title screen ---
def title_screen():
    clr()
    W = 20  # inner width (VIC-20 was 22 cols, borders take 2)
    top = "┌" + "─" * W + "┐"
    bot = "└" + "─" * W + "┘"
    mid = "├" + "─" * W + "┤"

    def row(s):
        return "│" + s.center(W) + "│"

    print(top)
    print(row(""))
    print(row("*OSAKESAASTAJAT*"))
    print(row(""))
    print(mid)
    print(row("══════════════"))
    print(row("(C)SAMI.K 1984"))
    print(row(""))
    print(bot)
    print()


# --- Lines 10-90: setup ---
def setup():
    clr()
    player_names = ["", ""]
    for i in range(2):
        while True:
            name = input(f"PELAAJAN {i + 1} NIMI: ").upper().strip()
            if len(name) > 6:
                print("6 KIRJA INTA.")
            elif name:
                player_names[i] = name
                break

    company_names = []
    for i in range(12):
        while True:
            name = input(f"YHTION {i + 1} NIMI: ").upper().strip()
            if len(name) > 8:
                print("8 KIRJA INTA.")
            elif name:
                company_names.append(name)
                break

    return player_names, company_names


# --- Lines 110-150: market table ---
def show_market(t, company_names, price_changes, prices, capital, player_names):
    clr()
    print("YHTIO    M.  OVH N:O:")
    print("─" * 22)
    for i in range(12):
        x = price_changes[i]
        xstr = f"{x:+d}" if x != 0 else " 0"
        name = f"{company_names[i]:<9}"
        print(f"{name}{xstr:>3} {prices[i]:>3}  {i + 1:>2}")
    print(f"\nTEKEEKO {player_names[t]}")
    print("OSTOJA? [K/E]")
    print(f"(VARAT {capital[t]})")


# --- Lines 110-250: buy phase ---
def buy_phase(t, company_names, prices, capital, holdings, price_changes, player_names):
    while True:
        show_market(t, company_names, price_changes, prices, capital, player_names)
        key = yn_prompt()
        if key == "E":
            return

        # get company number
        while True:
            q = get_int("N:O: ") - 1
            if 0 <= q < 12:
                break
            sys.stdout.write(f"{CUU}{EL}")
            sys.stdout.flush()

        # get quantity
        while True:
            w = get_int("KPL: ")
            if w > 0:
                break
            sys.stdout.write(f"{CUU}{EL}")
            sys.stdout.flush()

        cost = w * prices[q]
        if capital[t] - cost < 0:
            print("EI VARAA.")
            press_any_key()
            continue

        capital[t] -= cost
        holdings[t][q] += w

        if capital[t] <= 0:
            return


# --- Lines 260-420: portfolio + sell phase ---
def sell_phase(t, company_names, prices, capital, holdings, player_names):
    while True:
        clr()
        print(f"PELAAJAN {t + 1} OSAKKEET")
        print()
        print("N:O NIMI     KPL")
        print("─" * 16)

        has_stocks = False
        for i in range(12):
            if holdings[t][i] > 0:
                print(f"{i + 1:<4}{company_names[i]:<9}{holdings[t][i]:>4}")
                has_stocks = True

        if not has_stocks:
            print("\nOSAKKEITA EIOLE.")
            press_any_key()
            return

        print("MYYTKO?")
        key = yn_prompt()
        if key == "E":
            return

        # get company number
        while True:
            q = get_int("NRO: ") - 1
            if 0 <= q < 12:
                break
            sys.stdout.write(f"{CUU}{EL}")
            sys.stdout.flush()

        # get quantity
        while True:
            w = get_int("KPL: ")
            if w > 0:
                break
            sys.stdout.write(f"{CUU}{EL}")
            sys.stdout.flush()

        if w > holdings[t][q]:
            print("EI OLE.")
            press_any_key()
            continue

        holdings[t][q] -= w
        proceeds = w * prices[q]
        capital[t] += proceeds
        print(f"SAATU {proceeds} MK.")
        print(f"PAAOMA {capital[t]} MK.")
        press_any_key()


# --- Lines 440-500: dividends ---
def dividends(player_names, company_names, prices, holdings, capital):
    clr()
    print("OSINGOT")
    for t in range(2):
        print(f"\n{player_names[t]}:LLE :")
        for i in range(12):
            if holdings[t][i] > 0:
                div = holdings[t][i] * (prices[i] // 10)
                pad = "-" * (10 - len(company_names[i]))
                print(f"{company_names[i]}{pad}{div} MK")
                capital[t] += div
    press_any_key()


# --- Subroutine 700: ask to quit ---
def ask_quit():
    clr()
    print("LOPETAMMEKO? [K/E]")
    return yn_prompt() == "K"


# --- Lines 580-630: stock split event ---
def osakeanti(i, company_names, prices, price_changes, holdings):
    clr()
    print("OSAKEANTI!")
    print(f"{company_names[i]} KAKSIN-")
    print("KERTAISTAA OSAKKEENSA.")
    for t in range(2):
        holdings[t][i] *= 2
    prices[i] = 100
    price_changes[i] = 0
    press_any_key()


# --- Lines 640-690: bankruptcy event ---
def konkurssi(i, company_names, prices, price_changes, holdings):
    clr()
    print(company_names[i])
    print("TEKI KONKURSSIN.")
    print("MENETITTE OSAKKEENNE.")
    for t in range(2):
        holdings[t][i] = 0
    prices[i] = 100
    price_changes[i] = 0
    press_any_key()


# --- Lines 510-560: update prices ---
def update_prices(company_names, prices, price_changes, holdings):
    for i in range(12):
        price_changes[i] = random.randint(0, 6) - 3
        prices[i] += 10 * price_changes[i]
        if prices[i] >= 200:
            osakeanti(i, company_names, prices, price_changes, holdings)
        elif prices[i] <= 0:
            konkurssi(i, company_names, prices, price_changes, holdings)


# --- Lines 800-950: end game calculation ---
def end_game(player_names, company_names, prices, holdings, capital):
    clr()
    print("VAROJEN LASKENTA")
    time.sleep(1.5)

    totals = [0, 0]
    for t in range(2):
        clr()
        print(f"{player_names[t]}:N VARAT")
        totals[t] = capital[t]
        for i in range(12):
            if holdings[t][i] > 0:
                value = holdings[t][i] * prices[i]
                pad = " " * (9 - len(company_names[i]))
                print(f"{company_names[i]}:{pad}{value} MK")
                totals[t] += value
        print(f"PAAOMA {totals[t]}")
        press_any_key()

    clr()
    print("LASKENTA SUORITETTU.")
    print()
    for i in range(2):
        print(f"\n{player_names[i]}:N VARAT = {totals[i]}")

    print()
    if totals[0] == totals[1]:
        print("\n\nREILU TASAPELI!")
    elif totals[0] > totals[1]:
        print(f"\n\n{player_names[0]} VOITTI!")
    else:
        print(f"\n\n{player_names[1]} VOITTI!")

    press_any_key()


# --- Main ---
def main():
    sys.stdout.write(f"{BLUE_BG}{WHITE}")
    sys.stdout.flush()

    title_screen()
    press_any_key()

    player_names, company_names = setup()

    prices       = [100] * 12
    capital      = [1200, 1200]
    holdings     = [[0] * 12, [0] * 12]
    price_changes = [0] * 12

    while True:
        for t in range(2):
            buy_phase(t, company_names, prices, capital, holdings, price_changes, player_names)
            sell_phase(t, company_names, prices, capital, holdings, player_names)

        dividends(player_names, company_names, prices, holdings, capital)

        if ask_quit():
            end_game(player_names, company_names, prices, holdings, capital)
            break

        update_prices(company_names, prices, price_changes, holdings)


if __name__ == "__main__":
    try:
        main()
    finally:
        sys.stdout.write(RESET + "\n")
        sys.stdout.flush()
