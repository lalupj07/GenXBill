# GenXBill - Setup & Run Instructions

## Environment Setup Status (Automated)
*   **Flutter SDK**: INSTALLED at `c:\Users\lalup\flutter_sdk`.
*   **PATH**: Updated permanently. You might need to restart VS Code to see it.
*   **Dependencies**: FIXED `bitsdojo_window` version mismatch.
*   **Project Config**: REPAIRED `windows/` output.

## Troubleshooting Build Failures
If `flutter run -d windows` fails with "Build process failed", it is likely due to missing Visual Studio C++ components.

1.  Open **Visual Studio Installer**.
2.  Modify your **Visual Studio 2022** installation.
3.  Ensure the **"Desktop development with C++"** workload is checked.
4.  Click **Modify/Install**.

## Run Application
Once VS components are ready:
```bash
flutter run -d windows
```

## Features Implemented
*   **Create Invoice**: Full form with Client Name, Date Pickers, Dynamic Items list.
*   **Database**: Uses **Hive** for fast local storage. Invoices are saved permanently.
*   **PDF Generation**: Generates professional PDF invoices with the correct data.
*   **Dashboard**: Shows real recent invoices and statistics.
*   **Invoices List**: Displays all saved invoices with status colors.
