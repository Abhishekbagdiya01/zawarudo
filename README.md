# 🌌 **Zawarudo**

*A CLI utility to track your work uptime, log your daily grind, and sprinkle some ASCII art magic into your terminal.*

---

## ✨ **Description**

**Zawarudo** is a Dart-powered command-line tool for:  
- tracking your daily login/logout times,  
- calculating your total worked hours & shift shortfall,  
- summarizing your monthly progress,  
- and making your terminal a little cooler with ASCII art.

Perfect for devs who want lightweight time tracking right in their terminal, without needing bloated apps or web tools.

---

## 🚀 **Features**

✅ **Work Hours Tracker** — Log login/logout times, track worked hours, and calculate daily & monthly shortfall against a target shift (default: 9h).  
✅ **Automatic Weekend Handling** — Ignores Saturdays & Sundays in shortfall calculations, so you can chill on weekends guilt-free.
✅ **Colorful Summaries** — Terminal output with color-coded stats for easy reading.  
✅ **ASCII Art Fun** — Adds a bit of style with nerdy ASCII art prints.  
✅ **Cross-platform** — Works on Linux & macOS.  
✅ **Simple Logs** — Stores logs in plain text (`logs/work_uptime_log.txt`) — easy to review & version control if needed.

---

## 🛠️ **Installation**

Make sure you have the **Dart SDK** installed on your system.  
Then clone this repository:

```bash
git clone https://github.com/Abhishekbagdiya01/zawarudo.git
cd zawarudo

To install Zawarudo, ensure you have the Dart SDK installed. Then, you can clone this repository:
## Usage

To run the Zawarudo application, navigate to the project root and execute:

```bash
dart bin/zawarudo.dart
```

Further usage instructions will depend on the specific commands and arguments supported by the application.

## Shell Integration (Zsh)

To automatically log your terminal start and exit times, you can bind the `zawarudo.dart` script to your Zsh shell. Add the following lines to your `~/.zshrc` file:

```bash
# Zawarudo: Log time on terminal start and exit
if [[ -o INTERACTIVE ]]; then
    dart run zawarudo/bin/zawarudo.dart
    zshexit() {
        dart run zawarudo/bin/zawarudo.dart
    }
fi
```

Remember to replace `zawarudo/` with the actual path to your `zawarudo` directory if it's different.

## Project Structure

```
.git/
bin/
└── zawarudo.dart
lib/
├── ascii_art.dart
├── logger.dart
└── time_calc.dart
logs/
└── work_uptime_log.txt
test/
```
