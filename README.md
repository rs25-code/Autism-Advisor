# Autism Advisor - IEP & 504 Plan Assistant

An iOS application that uses AI to analyze IEP (Individualized Education Program) and 504 plan documents, providing actionable insights and support for students with autism and ADHD.

## 🎯 Purpose

This app helps parents, teachers, and counselors understand and implement educational support plans more effectively by leveraging OpenAI's API to analyze documents and provide personalized recommendations.

## Requirements

<img width="1676" height="843" alt="image" src="https://github.com/user-attachments/assets/8db4d36b-a105-4bf2-b83f-9cc05592237d" />


## ✨ Features

### Document Analysis
- **PDF Upload & Processing**: Upload IEP and 504 plan documents for comprehensive AI analysis
- **Smart Document Parsing**: Extract and analyze key information from educational plans
- **Multi-language Support**: Available in English, Spanish, and Korean

### AI-Powered Insights
- **Comprehensive Analysis**: Get detailed breakdowns of strengths, concerns, and recommendations
- **Goal Tracking**: Monitor progress on educational goals with visual progress indicators
- **Service Breakdown**: Understand required services, frequency, and providers
- **Overall Scoring**: Quick assessment of plan quality (0-100 scale)

### Role-Based Interface
Customized experiences for different user types:
- **Parents**: Track child's progress, understand IEP documents, get home support strategies
- **Teachers**: Create lesson plans, monitor student progress, collaborate with IEP teams
- **Counselors**: Coordinate services, facilitate meetings, manage multiple student cases

### Interactive Q&A
- Ask questions about uploaded documents
- Get AI-powered answers based on document content
- Maintain conversation history for context

### Supabase Integration
- Secure user authentication
- Cloud storage for documents
- Cross-device synchronization
- User profiles and preferences

## 🛠 Technology Stack

- **Platform**: iOS 15.0+
- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **AI Integration**: OpenAI GPT-4o-mini API
- **Backend**: Supabase (Authentication & Database)
- **Document Processing**: PDFKit
- **Architecture**: MVVM pattern with ObservableObject state management

## 📋 Prerequisites

- Xcode 14.0 or later
- iOS 15.0+ deployment target
- OpenAI API key
- Supabase project credentials

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/iep-504-assistant.git
cd iep-504-assistant
```

### 2. Configure API Keys

Create or edit your `Info.plist` file to include:

```xml
<key>OPENAI_API_KEY</key>
<string>your-openai-api-key-here</string>
<key>SUPABASE_URL</key>
<string>your-supabase-url-here</string>
<key>SUPABASE_ANON_KEY</key>
<string>your-supabase-anon-key-here</string>
```

**Alternative**: Set environment variables for development:
```bash
export OPENAI_API_KEY="your-openai-api-key"
export SUPABASE_URL="your-supabase-url"
export SUPABASE_ANON_KEY="your-supabase-anon-key"
```

### 3. Install Dependencies

This project uses Swift Package Manager. Dependencies should resolve automatically in Xcode.

**Required Packages**:
- Supabase Swift Client

### 4. Configure Supabase Database

Run the included database schema on your Supabase project:
```sql
-- See Supabase Schema file for complete database structure
```

### 5. Build and Run

1. Open `AutismApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

## 📁 Project Structure

```
AutismApp/
├── App/
│   ├── AutismApp.swift          # App entry point
│   └── ContentView.swift        # Root navigation
├── Screens/
│   ├── LandingScreen.swift      # Welcome screen
│   ├── RoleSelection.swift      # User role selection
│   ├── LoginScreen.swift        # Authentication
│   ├── DashboardScreen.swift    # Main dashboard
│   ├── UploadScreen.swift       # Document upload
│   ├── AnalysisScreen.swift     # Analysis results
│   ├── QAScreen.swift           # Q&A interface
│   └── ProfileScreen.swift      # User profile
├── Views/
│   ├── SummaryTabView.swift     # Analysis summary
│   ├── GoalsTabView.swift       # Goals tracking
│   ├── ServicesTabView.swift    # Services breakdown
│   ├── InsightsTabView.swift    # AI insights
│   └── GamePlanTabView.swift    # Action plans
├── Services/
│   ├── OpenAIService.swift      # OpenAI API integration
│   ├── OpenAIMultilingualService.swift # Multi-language support
│   ├── SupabaseService.swift    # Backend integration
│   ├── DocumentProcessor.swift  # PDF processing
│   ├── TTSService.swift         # Text-to-speech
│   └── VoiceInputService.swift  # Voice recognition
├── Models/
│   ├── Models.swift             # Data models
│   └── AppState.swift           # App state management
└── Utilities/
    ├── ColorTheme.swift         # Color schemes
    ├── ButtonStyles.swift       # Custom button styles
    └── TTSUIComponents.swift    # TTS UI elements
```

## 🔑 Key Components

### AppState
Central state management using `@EnvironmentObject`:
- User authentication state
- Current document and analysis
- Navigation flow
- Service instances

### OpenAI Integration
- Document analysis with structured JSON responses
- Conversational Q&A with context
- Multi-language support (English, Spanish, Korean)
- Error handling and retry logic

### Document Processing
- PDF text extraction
- Content parsing and structuring
- Metadata extraction
- Cloud storage integration

### Supabase Services
- User authentication (email/password)
- Document storage and retrieval
- User profiles and preferences
- Real-time data synchronization

## 🌐 Supported Languages

- **English**: Full support
- **Spanish**: Complete translations and AI responses
- **Korean**: Complete translations and AI responses

## 📊 Database Schema

The app uses Supabase PostgreSQL with the following main tables:
- `users`: User accounts and profiles
- `students`: Student information
- `support_documents`: Uploaded IEP/504 documents
- `support_goals`: Educational goals and tracking
- `support_services`: Service requirements
- `goal_progress_entries`: Progress tracking data
- `meetings`: IEP meeting scheduling
- `notifications`: User notifications

## 🔒 Security & Privacy

- API keys stored securely in Info.plist (excluded from version control)
- Supabase Row Level Security (RLS) policies
- Encrypted data transmission
- User authentication required for all operations
- Document access controlled by user permissions

## 🧪 Testing

Currently, the app includes:
- Manual testing workflows
- Debug logging for development
- Error handling with user-friendly messages

## 📱 App Store Preparation

### Required Steps:
1. ✅ Complete app functionality
2. ⏳ Create App Store Connect listing
3. ⏳ Design app icons and screenshots
4. ⏳ Prepare privacy policy
5. ⏳ Submit for App Review

### Privacy Considerations:
- Educational documents contain sensitive information
- FERPA and COPPA compliance required
- Clear privacy policy needed
- Parental consent for users under 13

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Swift naming conventions
- Use SwiftUI best practices
- Add comments for complex logic
- Keep functions focused and modular

## 📝 License

[Add your chosen license here - e.g., MIT, Apache 2.0]

## 👥 Authors

[Your name/team information]

## 🙏 Acknowledgments

- OpenAI for GPT API
- Supabase for backend infrastructure
- Special education community for feedback and requirements

## 📧 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: [your-email@example.com]

## 🗺 Roadmap

### Upcoming Features:
- [ ] Voice input for Q&A
- [ ] Document comparison tools
- [ ] Progress reports generation
- [ ] Meeting scheduling integration
- [ ] Collaboration features
- [ ] Offline mode support
- [ ] Apple Watch companion app
- [ ] iPad optimization

### Future Enhancements:
- [ ] Machine learning for predictive insights
- [ ] Integration with school management systems
- [ ] Customizable report templates
- [ ] Parent-teacher communication portal
- [ ] Resource library
- [ ] Community forum

## ⚠️ Disclaimer

This app is designed to assist with understanding and implementing educational support plans. It is not a replacement for professional educational or medical advice. Always consult with qualified professionals for decisions regarding student education and support services.

---

**Version**: 1.0.0  
**Last Updated**: November 2025  
**Status**: Active Development
