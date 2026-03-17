# GenXBill Enhanced Invoice Template Guide

## Overview

GenXBill now includes a **completely redesigned professional invoice PDF template** with comprehensive details, modern design, and enhanced information display.

---

## 🎨 New Enhanced Template Features

### 1. **Modern Professional Design**
- Clean, organized layout with proper spacing
- Color-coded sections for easy readability
- Professional borders and separators
- Alternating row colors in item table for better visibility

### 2. **Comprehensive Header Section**
- **Top Bar**: GSTIN display + "ORIGINAL FOR RECIPIENT" badge
- **Company Logo**: 80x80px logo with rounded corners
- **Company Details**: 
  - Company name (large, bold, blue)
  - Full address
  - Email and phone
  - Website (if available)

### 3. **Enhanced Invoice Title**
- Dynamic title based on invoice type:
  - "TAX INVOICE (INTERSTATE)" for interstate transactions
  - "TAX INVOICE / BILL OF SUPPLY" for intrastate

### 4. **Detailed Invoice Information**
- **Invoice Number**: Prominently displayed
- **Invoice Date**: Formatted as dd-MMM-yyyy
- **Due Date**: Highlighted in red for visibility
- **Status Badge**: Visual indicator for paid invoices

### 5. **Comprehensive Billing & Shipping Details**

#### Bill To Section (Left)
- Client name (bold, large)
- Full billing address
- GSTIN (if available)
- State Code
- Phone number
- Email address

#### Ship To Section (Right)
- Shipping address
- Destination
- Transport mode
- Dispatched through
- Delivery note

### 6. **Order Reference Information**
- Order Number
- Order Date
- Payment Terms
- PO Number

### 7. **Enhanced Items Table**
Columns:
1. **S.No** - Serial number
2. **Item Description** - Product/service name
3. **HSN/SAC Code** - Tax classification code
4. **Qty** - Quantity (2 decimal places)
5. **Unit** - Unit of measurement
6. **Rate** - Unit price (2 decimal places)
7. **Disc.** - Discount percentage
8. **Tax %** - Tax rate (default 18%)
9. **Amount** - Line total

Features:
- Alternating row colors (white/grey)
- Minimum 10 rows for professional appearance
- Proper column widths to prevent text overflow
- Header row with blue background

### 8. **Comprehensive Totals Section**

#### Left Side: Amount in Words
- Total invoice amount spelled out in words
- "Rupees Only" format
- Tax summary box with:
  - Taxable amount
  - IGST/CGST/SGST breakdown
  - Total tax amount

#### Right Side: Amount Breakdown
- Subtotal
- Packaging/Courier charges (if applicable)
- Taxable amount (bold)
- Tax breakdown:
  - **Interstate**: IGST @ 18%
  - **Intrastate**: CGST @ 9% + SGST @ 9%
- **Grand Total** (large, bold, blue background)

### 9. **Payment Information Section**
- Invoice status with color coding:
  - **Paid**: Green
  - **Overdue**: Red
  - **Draft/Sent**: Orange
- Total amount display

### 10. **Bank Details Section**
Professional display with:
- Bank name
- Account number
- IFSC code
- Branch name

All in a blue-tinted box for easy identification.

### 11. **Additional Notes**
- Customer notes (if provided)
- Displayed in a dedicated section

### 12. **Terms & Conditions**
Default terms:
1. Goods once sold will not be taken back or exchanged
2. Interest @ 18% p.a. for late payments
3. Jurisdiction clause
4. Delivery acceptance clause

Can be customized in app settings.

### 13. **Professional Footer**

#### Left: Declaration
- Standard declaration text
- "E. & O.E." (Errors and Omissions Excepted)

#### Center: Company Stamp
- 70x70px stamp image (if provided)

#### Right: Authorized Signature
- 100x50px signature image (if provided)
- "Authorised Signatory" label
- Company name

---

## 📊 Comparison: Old vs New Template

| Feature | Old Template | Enhanced Template |
|---------|-------------|-------------------|
| **Design** | Basic borders | Modern, color-coded sections |
| **Header** | Simple logo + name | Comprehensive company info |
| **Client Info** | Basic details | Full billing + shipping split |
| **Items Table** | 7 columns | 9 columns with discount & tax |
| **Totals** | Simple breakdown | Amount in words + tax summary |
| **Payment Info** | Not included | Status badge + amount display |
| **Bank Details** | Single line | Organized box with all details |
| **Footer** | Basic signature | Declaration + stamp + signature |
| **Color Coding** | Minimal | Strategic use throughout |
| **Spacing** | Tight | Generous, professional |

---

## 🚀 How to Use

### Option 1: Use Enhanced Template (Recommended)

```dart
import 'package:genx_bill/core/services/enhanced_invoice_template.dart';

// Generate PDF
final pdf = await EnhancedInvoiceTemplate.generatePDF(invoice, settings);

// Save to file
final file = File('invoice.pdf');
await file.writeAsBytes(await pdf.save());
```

### Option 2: Keep Using Professional Template

The existing `ProfessionalInvoiceTemplate` is still available and fully functional.

```dart
import 'package:genx_bill/core/services/professional_invoice_template.dart';

final widget = await ProfessionalInvoiceTemplate.buildInvoice(invoice, settings);
```

---

## 🎨 Customization Options

### 1. Company Branding
Set in **Settings → Company Settings**:
- Company Logo (recommended: 200x200px PNG with transparency)
- Company Stamp (recommended: 200x200px PNG)
- Signature (recommended: 300x150px PNG with transparency)

### 2. Bank Details
Configure in **Settings → Bank Details**:
- Bank Name
- Account Number
- IFSC Code
- Branch Name

### 3. Terms & Conditions
Customize in **Settings → Invoice Settings**:
- Default terms text
- Maximum 5 lines recommended

### 4. Colors
Current color scheme:
- **Primary**: Blue (#1E3A8A - blue900)
- **Success**: Green (#15803D - green700)
- **Warning**: Orange (#C2410C - orange700)
- **Danger**: Red (#B91C1C - red700)

---

## 📋 Invoice Data Requirements

### Required Fields
- `invoiceNumber` - Unique invoice identifier
- `clientName` - Customer name
- `date` - Invoice date
- `dueDate` - Payment due date
- `items` - List of invoice items
- `status` - Invoice status (draft/sent/paid/overdue)

### Recommended Fields
- `clientAddress` - For billing section
- `clientGstin` - For tax compliance
- `clientPhone` - For contact
- `clientEmail` - For communication
- `shippingAddress` - If different from billing
- `orderNumber` - Purchase order reference
- `paymentTerms` - Payment conditions
- `notes` - Additional information

### Optional Fields
- `poNumber` - Purchase order number
- `poDate` - PO date
- `transportMode` - Shipping method
- `courierCharges` - Additional charges
- `destination` - Delivery location
- `dispatchedThrough` - Courier/transport company
- `deliveryNote` - Delivery instructions

---

## 💡 Best Practices

### 1. Image Quality
- **Logo**: Use high-resolution PNG with transparency
- **Signature**: Scan at 300 DPI minimum
- **Stamp**: Clear, high-contrast image

### 2. Data Entry
- Always fill GSTIN for tax compliance
- Include complete addresses
- Specify HSN/SAC codes for items
- Set proper payment terms

### 3. Professional Appearance
- Use consistent units (Pcs, Nos, Kg, etc.)
- Round amounts appropriately
- Include all tax information
- Add relevant notes

### 4. File Management
- Use descriptive filenames: `INV-001-ClientName-2026.pdf`
- Store in organized folders
- Keep backups

---

## 🔧 Technical Details

### PDF Specifications
- **Page Format**: A4 (210mm x 297mm)
- **Margins**: 15px all sides
- **Font Sizes**: 
  - Title: 14pt
  - Headers: 8-10pt
  - Body: 6.5-7pt
  - Small text: 6pt

### Color Codes (PdfColors)
- `blue900`: #1E3A8A
- `blue50`: #EFF6FF
- `green700`: #15803D
- `green50`: #F0FDF4
- `red700`: #B91C1C
- `red50`: #FEF2F2
- `grey100`: #F3F4F6
- `grey50`: #F9FAFB

### Dependencies
- `pdf: ^3.10.0` - PDF generation
- `intl: ^0.18.0` - Date formatting

---

## 📝 Number to Words Conversion

The template includes Indian numbering system support:
- Ones, Tens, Hundreds
- Thousands
- Lakhs
- Crores

Example: ₹1,25,450.00 → "One Lakh Twenty Five Thousand Four Hundred Fifty Rupees Only"

---

## 🐛 Troubleshooting

### Issue: Logo not displaying
**Solution**: Ensure logo file path is correct and file exists. Use absolute path.

### Issue: Text overflow in table
**Solution**: Keep item descriptions concise (max 50 characters recommended).

### Issue: Missing bank details
**Solution**: Configure bank details in Settings → Bank Details.

### Issue: Incorrect tax calculation
**Solution**: Verify `isInterstate` flag is set correctly based on client state code.

---

## 🔄 Migration from Old Template

To switch from `ProfessionalInvoiceTemplate` to `EnhancedInvoiceTemplate`:

1. Update import statement
2. Change method call from `buildInvoice()` to `generatePDF()`
3. The new template returns `pw.Document` instead of `pw.Widget`

**Before:**
```dart
final widget = await ProfessionalInvoiceTemplate.buildInvoice(invoice, settings);
final pdf = pw.Document();
pdf.addPage(pw.Page(build: (context) => widget));
```

**After:**
```dart
final pdf = await EnhancedInvoiceTemplate.generatePDF(invoice, settings);
```

---

## 📞 Support

For issues or feature requests related to invoice templates:
1. Check this guide first
2. Review sample invoices in the app
3. Contact GenXis Inc support

---

**Version**: 5.2.0  
**Last Updated**: March 17, 2026  
**Template**: Enhanced Invoice Template v1.0
