# Library Management System
### CSE341 – Microprocessors

A console-based **Library Management System** written in **x86 Assembly (MASM)** for the 8086/8088 processor. The system supports two roles — Admin and User — each with their own authentication and set of operations.

---

## Features

### Admin
- Secure 4-digit PIN login (3 attempts before lockout)
- Add new books (title + author, up to 10 books)
- List all books in the database
- Search for a book by **title** or **author**
- Update a book's title
- Delete a book from the database
- View and mark overdue books

### User
- Login with User ID + 4-digit PIN (3 attempts before lockout)
- List all available books
- Search for a book by title or author
- Borrow a book
- Return a borrowed book
- View personally borrowed books
- Overdue warning alert (with beep) on login if a borrowed book is overdue

---

## Default Credentials

### Admin
| Field | Value |
|-------|-------|
| PIN   | `1234` |

### Users
| User ID | PIN    |
|---------|--------|
| `a`     | `1111` |
| `b`     | `2222` |
| `c`     | `3333` |
| `d`     | `4444` |

---

## Pre-loaded Books

| ID | Title     | Author         | Status |
|----|-----------|----------------|--------|
| 0  | Cosmos    | Carl Sagan     | A      |
| 1  | Dune      | Frank Herbert  | A      |

*(Status: `A` = Available, `B` = Borrowed)*

---

## Requirements

- **IDE/Emulator:** [emu8086](https://emu8086-microprocessor-emulator.en.download.it/) — a microprocessor emulator for Windows that includes an assembler, linker, and debugger for 8086 assembly
- **OS:** Windows (any version supported by emu8086)

---

## How to Assemble & Run

1. Install and open **emu8086**.

2. Click **File → Open** and select `10_01_22299391_22201405_22201748.asm`.

3. Click **Emulate** (or press `F5`) to assemble and load the program into the emulator.

4. Click **Run** to execute the program. The console window will appear and you can interact with the system.

---

## Project Structure

```
├── 10_01_22299391_22201405_22201748.asm   # Main source file
└── README.md
```

---

## Technical Notes

- Written using the `.MODEL SMALL` memory model with a 256-byte stack segment
- Book database supports up to **10 entries**, each with a 20-character title and author field
- Book data is stored in flat parallel arrays (IDs, titles, authors, statuses, borrower IDs, overdue flags)
- All I/O is performed via **DOS INT 21h** service calls
- PIN input is masked with `*` characters

---

## Credits

This project was developed as a group project for **CSE341 – Microprocessors**.

| Name            | Student ID  |
|-----------------|-------------|
| Rhythm          | 22201748    |
| Bushra Mehreen  | 22201405    |
| Nehal Mahfuz    | 22299391    |

---
