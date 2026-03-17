# GenXBill Changelog

## [5.2.0] - 2026-03-11

### 🎉 Major Features

#### Smart Analytics Dashboard
- Real-time business insights with comprehensive data visualization
- Revenue trends with 30-day line charts
- Top products analysis with sales metrics
- Customer payment behavior with credit scoring (0-100)
- Cash flow forecasting for 30/60/90 days
- Key metrics dashboard with glass morphism UI

#### Invoice Themes System
- 5 predefined professional themes (Modern, Classic, Minimal, Corporate, Colorful)
- Theme selector UI in Settings
- Visual theme preview with instant switching
- Persistent theme storage

#### Automated Payment Reminders
- Smart reminder scheduling (7 days before to 14 days after due date)
- Multi-channel support (Email and WhatsApp)
- Professional reminder templates
- Reminder control panel in Settings
- Statistics dashboard for active and overdue reminders

### 🔧 Technical Improvements
- Generated Hive type adapters for all new models (typeIds 10-15)
- Repository pattern implementation (InvoiceThemeRepository, ReminderRepository)
- Riverpod state management providers
- Service layer for analytics and reminders
- Zero deprecation warnings - updated to latest Flutter APIs
- Const optimization and code quality improvements

### 📦 Database Changes
- New Hive boxes: invoice_themes, payment_reminders
- Automatic initialization of predefined themes
- Data persistence for all settings

### 🐛 Bug Fixes
- Fixed model field name mismatches
- Corrected type conversion errors
- Resolved switch statement exhaustiveness issues

---

## [5.1.0] - 2026-02-22

### 🎉 Major Features

#### WhatsApp Invoice Sending
- **Automatic PDF sharing to client's WhatsApp** - Send invoices directly from the billing window
- Smart phone number validation with auto-formatting for Indian numbers (+91)
- Visual checkbox with green chat icon showing client's phone number
- Seamless integration with WhatsApp Web and Desktop app
- Non-blocking operation - invoice saves even if WhatsApp fails
- Success/error notifications for user feedback

#### Professional Invoice Template Enhancements
- **Perfectly centered header address** - Company details now properly aligned
- **Extended invoice content** - Bill extends to page bottom with 8 minimum rows for better space utilization
- **Complete bank details section** - Displays Bank Name, Account Number, IFSC Code, and Branch
- **Optimized table layout** - Proper column widths prevent text overflow
- **Perfect A4 formatting** - 15px margins for professional printing
- **Beautiful spacing and alignment** - All sections properly formatted

#### Product Search Improvement
- **Auto-clear search field** - Product search automatically clears after adding item
- Improved workflow for adding multiple items quickly
- No manual clearing required - ready for next search immediately

### 🔧 Technical Improvements

#### Invoice PDF Generation
- Fixed header alignment with proper container centering
- Increased table rows from 5 to 8 for better page utilization
- Optimized font sizes (6-7pt) to prevent text overflow
- Added proper text wrapping with maxLines and overflow handling
- Multi-line bank details layout with all fields displayed

#### WhatsApp Integration
- Created comprehensive WhatsAppService with phone validation
- Auto-formats phone numbers with country code
- Saves PDF to temporary directory for sharing
- Fallback mechanism (WhatsApp Web → Desktop app)
- Proper error handling and user notifications

#### Code Quality
- Clean separation of concerns
- Proper error handling throughout
- User-friendly feedback messages
- Maintained backward compatibility
- Improved code documentation

### 📋 Bug Fixes
- Fixed invoice header address not being centered
- Fixed bank details section showing incomplete information
- Fixed product search field retaining previous search text
- Fixed table text overflow in invoice PDF
- Fixed invoice content not extending to bottom of page

### 🎨 UI/UX Improvements
- Better visual feedback for WhatsApp sending option
- Improved invoice PDF layout and spacing
- Enhanced product search workflow
- More professional invoice appearance
- Clearer bank details presentation

---

## [5.0.0] - 2026-02-21

### Initial Release
- Professional GST invoice template
- Complete billing ecosystem
- Inventory management
- Client and product management
- Multi-language support
- Dark/Light theme
- PDF generation and printing
- Email integration
- Multi-user support with roles
- Credit limit tracking
- Comprehensive reporting

---

**Note:** This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.
