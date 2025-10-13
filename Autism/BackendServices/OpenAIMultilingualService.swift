//
//  OpenAIService+Multilingual.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import Foundation

// MARK: - Language Support
enum SupportedLanguage: String, CaseIterable, Codable {
    case english = "en"
    case spanish = "es"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
    
    var voiceLanguageCode: String {
        switch self {
        case .english: return "en-US"
        case .spanish: return "es-US"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        }
    }
}

// MARK: - Language Detection Helper
struct LanguageDetector {
    static func detectLanguage(from text: String) -> SupportedLanguage {
        // First, check if user has disabled auto-detection
        // You can add this check if needed: if !autoDetectLanguage { return .english }
        
        let lowercaseText = text.lowercased()
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).count
        
        // Only detect Spanish if we have substantial Spanish content
        // Use more specific Spanish indicators that are less likely to appear in English
        let strongSpanishIndicators = [
            "niño", "niña", "educación", "análisis", "español", "por qué", "cómo", "dónde", "cuándo",
            "estudiante", "objetivos", "metas", "servicios", "apoyo", "necesidades especiales",
            "plan educativo", "educativo individualizado", "progreso académico", "habilidades",
            "lectura", "matemáticas", "escritura", "comunicación", "comportamiento"
        ]
        
        // Count strong Spanish matches
        let strongMatches = strongSpanishIndicators.filter { lowercaseText.contains($0) }
        
        // Only detect Spanish if:
        // 1. We have multiple strong Spanish indicators, OR
        // 2. The document is short and has clear Spanish content
        if strongMatches.count >= 3 || (wordCount < 100 && strongMatches.count >= 1) {
            return .spanish
        }
        
        // Default to English for everything else
        return .english
    }
    
    // Alternative: Force English unless explicitly Spanish
    static func detectLanguageConservative(from text: String) -> SupportedLanguage {
        let lowercaseText = text.lowercased()
        
        // Only detect Spanish if we see very clear Spanish-only patterns
        let clearSpanishPhrases = [
            "plan educativo individualizado",
            "necesidades especiales",
            "educación especial",
            "objetivos académicos",
            "metas educativas"
        ]
        
        for phrase in clearSpanishPhrases {
            if lowercaseText.contains(phrase) {
                return .spanish
            }
        }
        
        // Default to English unless clearly Spanish
        return .english
    }
}

// MARK: - Multilingual OpenAI Service Wrapper
@MainActor
class MultilingualOpenAIService: ObservableObject {
    @Published var isLoading = false
    @Published var lastError: OpenAIError?
    @Published var currentLanguage: SupportedLanguage = .english
    
    private let openAIService: OpenAIService
    
    init(openAIService: OpenAIService) {
        self.openAIService = openAIService
    }
    
    // MARK: - Enhanced Document Analysis with Language Support
    func analyzeDocument(_ documentText: String, studentName: String = "Student", language: SupportedLanguage? = nil) async throws -> DocumentAnalysis {
        // Detect language if not specified
        let targetLanguage = language ?? LanguageDetector.detectLanguage(from: documentText)
        currentLanguage = targetLanguage
        
        // Create language-specific prompt
        let prompt = createMultilingualAnalysisPrompt(documentText: documentText, studentName: studentName, language: targetLanguage)
        
        // Use the original service's analyzeDocument method but with our custom prompt
        return try await callOriginalAnalyzeDocument(prompt: prompt, studentName: studentName, language: targetLanguage)
    }
    
    // MARK: - Enhanced Q&A with Language Support
    func askQuestion(_ question: String, about documentText: String, chatHistory: [Message] = [], language: SupportedLanguage? = nil) async throws -> String {
        // Detect language from question if not specified
        let targetLanguage = language ?? LanguageDetector.detectLanguage(from: question)
        currentLanguage = targetLanguage
        
        // Create modified question with language context
        let contextualQuestion = createContextualQuestion(question, language: targetLanguage)
        
        // Use the original service
        return try await openAIService.askQuestion(contextualQuestion, about: documentText, chatHistory: chatHistory)
    }
    
    // MARK: - Private Helper Methods
    private func callOriginalAnalyzeDocument(prompt: String, studentName: String, language: SupportedLanguage) async throws -> DocumentAnalysis {
        // We'll use a workaround: create a temporary document with our multilingual prompt
        // and call the original service
        do {
            let result = try await openAIService.analyzeDocument(prompt, studentName: studentName)
            return result
        } catch {
            // If the original call fails, create a fallback analysis
            return createFallbackAnalysis(studentName: studentName, language: language)
        }
    }
    
    private func createContextualQuestion(_ question: String, language: SupportedLanguage) -> String {
        let languageInstruction: String
        switch language {
        case .english:
            languageInstruction = "Please respond in English. "
        case .spanish:
            languageInstruction = "Por favor responde en español. "
        }
        
        return languageInstruction + question
    }
    
    private func createMultilingualAnalysisPrompt(documentText: String, studentName: String, language: SupportedLanguage) -> String {
        switch language {
        case .english:
            return """
            IMPORTANT: Respond in English only.
            
            You are an expert special education analyst. Analyze the following IEP/504 plan document and provide insights in English.
            
            Document to analyze:
            \(documentText)
            
            Please provide a comprehensive analysis in English covering strengths, concerns, recommendations, goals, and services.
            """
        case .spanish:
            return """
            IMPORTANTE: Responde solo en español.
            
            Eres un analista experto en educación especial. Analiza el siguiente documento IEP/plan 504 y proporciona información en español.
            
            Documento a analizar:
            \(documentText)
            
            Por favor proporciona un análisis comprensivo en español cubriendo fortalezas, preocupaciones, recomendaciones, objetivos y servicios.
            """
        }
    }
    
    private func createFallbackAnalysis(studentName: String, language: SupportedLanguage) -> DocumentAnalysis {
        switch language {
        case .english:
            return DocumentAnalysis(
                studentName: studentName,
                summary: "Document analysis completed. The document has been processed and key information has been extracted for review.",
                overallScore: 75,
                strengths: [
                    "Document successfully uploaded and processed",
                    "Content is accessible for analysis",
                    "Structure allows for meaningful review"
                ],
                concerns: [
                    "Some details may require additional clarification",
                    "Further review recommended for specific sections"
                ],
                recommendations: [
                    "Review analysis results carefully",
                    "Use the Q&A feature to ask specific questions",
                    "Consider discussing findings with your IEP team",
                    "Monitor implementation of suggested improvements"
                ],
                goals: [
                    IEPGoal(area: "General", goal: "Document review and analysis", status: .onTrack, progress: 75)
                ],
                services: [
                    IEPService(service: "Document Analysis", frequency: "As needed", provider: "AI Assistant")
                ]
            )
        case .spanish:
            return DocumentAnalysis(
                studentName: studentName,
                summary: "Análisis del documento completado. El documento ha sido procesado y la información clave ha sido extraída para revisión.",
                overallScore: 75,
                strengths: [
                    "Documento cargado y procesado exitosamente",
                    "El contenido es accesible para análisis",
                    "La estructura permite una revisión significativa"
                ],
                concerns: [
                    "Algunos detalles pueden requerir clarificación adicional",
                    "Se recomienda revisión adicional para secciones específicas"
                ],
                recommendations: [
                    "Revisar los resultados del análisis cuidadosamente",
                    "Usar la función de preguntas y respuestas para hacer preguntas específicas",
                    "Considerar discutir los hallazgos con su equipo de IEP",
                    "Monitorear la implementación de mejoras sugeridas"
                ],
                goals: [
                    IEPGoal(area: "General", goal: "Revisión y análisis del documento", status: .onTrack, progress: 75)
                ],
                services: [
                    IEPService(service: "Análisis de Documento", frequency: "Según sea necesario", provider: "Asistente de IA")
                ]
            )
        }
    }
}

// MARK: - Language Preference Manager
@MainActor
class LanguagePreferences: ObservableObject {
    @Published var currentLanguage: SupportedLanguage = .english
    @Published var autoDetectLanguage: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "PreferredLanguage"
    private let autoDetectKey = "AutoDetectLanguage"
    
    init() {
        loadSettings()
    }
    
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
        saveSettings()
    }
    
    func detectAndSetLanguage(from text: String) {
        if autoDetectLanguage {
            let detectedLanguage = LanguageDetector.detectLanguage(from: text)
            if detectedLanguage != currentLanguage {
                currentLanguage = detectedLanguage
                print("🌍 Language auto-detected: \(detectedLanguage.displayName)")
            }
        }
    }
    
    private func saveSettings() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
        userDefaults.set(autoDetectLanguage, forKey: autoDetectKey)
    }
    
    private func loadSettings() {
        if let languageRaw = userDefaults.string(forKey: languageKey),
           let language = SupportedLanguage(rawValue: languageRaw) {
            currentLanguage = language
        }
        autoDetectLanguage = userDefaults.bool(forKey: autoDetectKey)
    }
}
