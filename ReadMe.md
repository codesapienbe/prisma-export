# **Prisma Export**

This project provides a set of Bash scripts to export Prisma schemas into various formats, such as **CSV**, **JSON**, **XML**, **Markdown**, and **Mermaid diagrams**. It is designed to be simple to use, extendable, and convenient for developers working with Prisma schemas.

---

## **Features**
- Export Prisma schemas into multiple formats:
  - **CSV**
  - **JSON**
  - **XML**
  - **Markdown**
  - **Mermaid diagrams**
- Generate visual ER diagrams with **Mermaid**.
- Convert Mermaid diagrams to **PDF** or **PNG** using **Mermaid CLI**.
- Modular design: Functions are separated into individual files for easy management.

---

## **Setup**

### **1. Clone the Repository**
```bash
git clone https://github.com/codesapienbe/prisma-export.git
cd prisma-export
```

### **2. Install Dependencies**
- Install **Mermaid CLI** for diagram generation (optional):
  ```bash
  npm install -g @mermaid-js/mermaid-cli
  ```
- Ensure you have the following tools installed:
  - **Bash**
  - **awk**
  - **Node.js** (for Mermaid CLI)

---

## **Usage**

### **Run the Main Script**
```bash
./prisma-export.sh <format> <prisma-file>
```

#### **Arguments**
- `<format>`: Export format (`csv`, `json`, `xml`, `md`, `mmd`).
- `<prisma-file>`: Path to your Prisma schema file (default is `schema.prisma`).

#### **Example**
```bash
./prisma-export.sh csv schema.prisma
```

### **Convert Mermaid Diagrams to PNG or PDF**
To convert Mermaid diagrams to PNG or PDF:
```bash
mmdc -i database.mmd -o database.png
mmdc -i database.mmd -o database.pdf
```

---

## **Directory Structure**
```plaintext
.
├── prisma-export.sh        # Main script
├── functions/              # Directory for individual export functions
│   ├── csv.sh              # CSV export script
│   ├── json.sh             # JSON export script
│   ├── xml.sh              # XML export script
│   ├── md.sh               # Markdown export script
│   └── mmd.sh              # Mermaid diagram export script
├── schema.prisma           # Example Prisma schema
└── .gitignore              # Git ignore rules
```

---

## **Contributing**
1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/my-new-feature
   ```
3. Make your changes and commit:
   ```bash
   git commit -m "Add some feature"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/my-new-feature
   ```
5. Open a pull request.

---

## **License**
This project is licensed under the [MIT License](LICENSE).

---

## **Acknowledgements**
- Inspired by Prisma and the need for efficient schema visualization and data exportation tools.
- Uses **Mermaid CLI** for diagram generation.