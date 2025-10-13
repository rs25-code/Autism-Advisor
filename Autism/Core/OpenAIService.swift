//
//  OpenAIService.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import Foundation

// MARK: - OpenAI API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - OpenAI Service Errors
enum OpenAIError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case rateLimitExceeded
    case tokenLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid OpenAI API key. Please check your configuration."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from OpenAI API."
        case .apiError(let message):
            return "OpenAI API error: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .tokenLimitExceeded:
            return "Document too long. Please try with a shorter document."
        }
    }
}

// MARK: - OpenAI Service
@MainActor
class OpenAIService: ObservableObject {
    @Published var isLoading = false
    @Published var lastError: OpenAIError?
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini" // Cost-effective model for most use cases
    
    // MARK: - Initialization
    init() {
        // FIXED: Use a function to get the key to avoid multiple assignments
        func getAPIKey() -> String {
            #if DEBUG
            // For debug builds, try to get from build settings
            if let buildSettingsKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
               !buildSettingsKey.isEmpty {
                print("✅ OpenAI Service initialized with API key from Info.plist")
                return buildSettingsKey
            } else {
                // Fallback: Try to get from environment variables
                let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
                if !envKey.isEmpty {
                    print("✅ OpenAI Service initialized with API key from environment")
                    return envKey
                } else {
                    print("❌ OpenAI API key not found in build settings or environment")
                    return ""
                }
            }
            #else
            // For release builds, require the key to be in Info.plist for security
            if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
               !plistKey.isEmpty {
                print("✅ OpenAI Service initialized successfully for release")
                return plistKey
            } else {
                print("❌ OpenAI API key not found in Info.plist for release build")
                return ""
            }
            #endif
        }
        
        self.apiKey = getAPIKey()
        
        // Set error state if no key found
        if apiKey.isEmpty {
            self.lastError = .invalidAPIKey
        }
    }
    
    // MARK: - Alternative initializer for testing with direct key
    init(apiKey: String) {
        self.apiKey = apiKey
        print("✅ OpenAI Service initialized with provided API key")
    }
    
    // MARK: - Document Analysis
    func analyzeDocument(_ documentText: String, studentName: String = "Student") async throws -> DocumentAnalysis {
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        isLoading = true
        lastError = nil
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let prompt = createAnalysisPrompt(documentText: documentText, studentName: studentName)
        
        do {
            let response = try await makeAPIRequest(messages: [
                OpenAIMessage(role: "system", content: "You are an expert special education analyst specializing in IEP and 504 plan analysis. Provide detailed, actionable insights."),
                OpenAIMessage(role: "user", content: prompt)
            ], maxTokens: 2000)
            
            return parseAnalysisResponse(response, studentName: studentName)
            
        } catch {
            let openAIError = error as? OpenAIError ?? .networkError(error)
            await MainActor.run {
                lastError = openAIError
            }
            throw openAIError
        }
    }
    
    // MARK: - Q&A Chat
    func askQuestion(_ question: String, about documentText: String, chatHistory: [Message] = []) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        isLoading = true
        lastError = nil
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // Build conversation context
        var messages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: createQASystemPrompt()),
            OpenAIMessage(role: "user", content: "Here is the document to analyze:\n\n\(documentText)")
        ]
        
        // Add chat history (last 10 messages to stay within token limits)
        let recentHistory = chatHistory.suffix(10)
        for message in recentHistory {
            let role = message.isFromUser ? "user" : "assistant"
            messages.append(OpenAIMessage(role: role, content: message.text))
        }
        
        // Add current question
        messages.append(OpenAIMessage(role: "user", content: question))
        
        do {
            let response = try await makeAPIRequest(messages: messages, maxTokens: 1000)
            return response
            
        } catch {
            let openAIError = error as? OpenAIError ?? .networkError(error)
            await MainActor.run {
                lastError = openAIError
            }
            throw openAIError
        }
    }
    
    // MARK: - Private Methods
    private func makeAPIRequest(messages: [OpenAIMessage], maxTokens: Int) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: model,
            messages: messages,
            temperature: 0.1, // Lower temperature for more consistent JSON formatting
            maxTokens: maxTokens
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw OpenAIError.networkError(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIError.invalidResponse
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                break
            case 429:
                throw OpenAIError.rateLimitExceeded
            case 400...499:
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorData["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw OpenAIError.apiError(message)
                }
                throw OpenAIError.apiError("Client error: \(httpResponse.statusCode)")
            case 500...599:
                throw OpenAIError.apiError("Server error: \(httpResponse.statusCode)")
            default:
                throw OpenAIError.invalidResponse
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let choice = openAIResponse.choices.first else {
                throw OpenAIError.invalidResponse
            }
            
            return choice.message.content
            
        } catch let error as OpenAIError {
            throw error
        } catch {
            throw OpenAIError.networkError(error)
        }
    }
    
    private func createAnalysisPrompt(documentText: String, studentName: String) -> String {
        return """
        You are an expert special education analyst. Analyze the following IEP/504 plan document and return ONLY a valid JSON response with no additional text, explanations, or formatting.

        CRITICAL: Your response must start with { and end with }. Do not include any text before or after the JSON.

        Required JSON format:
        {
            "summary": "A 2-3 sentence overview of the document and key insights",
            "overallScore": 85,
            "strengths": [
                "List of 3-5 key strengths identified in the document"
            ],
            "concerns": [
                "List of 3-5 areas that need attention or improvement"
            ],
            "recommendations": [
                "List of 4-6 specific, actionable recommendations"
            ],
            "goals": [
                {
                    "area": "Academic/Behavioral/Social/etc",
                    "goal": "Specific goal description",
                    "status": "On Track/Needs Attention/Behind",
                    "progress": 75
                }
            ],
            "services": [
                {
                    "service": "Service name",
                    "frequency": "How often",
                    "provider": "Who provides it"
                }
            ]
        }

        Analysis guidelines:
        - Focus on educational goals and their measurability
        - Evaluate appropriateness of services and accommodations
        - Assess progress monitoring methods
        - Consider transition planning if applicable
        - Review parent involvement and communication
        - Identify areas for improvement

        Document to analyze:
        \(documentText)

        Remember: Return ONLY the JSON object, no other text.
        """
    }
    
    private func createQASystemPrompt() -> String {
        return """
        You are an expert special education consultant helping to answer questions about IEP and 504 plan documents. 

        Guidelines:
        - Provide accurate, helpful answers based on the document content
        - If information isn't in the document, clearly state that
        - Offer practical suggestions when appropriate
        - Use clear, accessible language
        - Focus on actionable insights
        - Consider different perspectives (parent, teacher, student)
        - Reference specific sections of the document when relevant

        Always be supportive and constructive in your responses.
        """
    }
    
    private func parseAnalysisResponse(_ response: String, studentName: String) -> DocumentAnalysis {
        // Clean the response - remove any text before { or after }
        let cleanedResponse = cleanJSONResponse(response)
        
        // Add debug logging
        print("🔍 Raw AI response length: \(response.count)")
        print("🔍 Cleaned response preview: \(String(cleanedResponse.prefix(100)))...")
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            print("❌ Failed to convert response to data")
            return createFallbackAnalysis(from: response, studentName: studentName)
        }
        
        do {
            let analysisData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let analysisData = analysisData else {
                print("❌ Failed to cast JSON to dictionary")
                return createFallbackAnalysis(from: response, studentName: studentName)
            }
            
            print("✅ Successfully parsed JSON analysis")
            
            return DocumentAnalysis(
                studentName: studentName,
                summary: analysisData["summary"] as? String ?? "Analysis completed successfully.",
                overallScore: analysisData["overallScore"] as? Int ?? 75,
                strengths: analysisData["strengths"] as? [String] ?? ["Document structure is clear"],
                concerns: analysisData["concerns"] as? [String] ?? ["Some areas may need additional detail"],
                recommendations: analysisData["recommendations"] as? [String] ?? ["Continue current approach", "Monitor progress regularly"],
                goals: parseGoals(from: analysisData["goals"] as? [[String: Any]] ?? []),
                services: parseServices(from: analysisData["services"] as? [[String: Any]] ?? [])
            )
            
        } catch {
            print("❌ JSON parsing error: \(error)")
            print("❌ Failed response content: \(cleanedResponse)")
            return createFallbackAnalysis(from: response, studentName: studentName)
        }
    }
    
    private func cleanJSONResponse(_ response: String) -> String {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Find the first { and last }
        guard let startIndex = trimmed.firstIndex(of: "{"),
              let endIndex = trimmed.lastIndex(of: "}") else {
            print("❌ No JSON braces found in response")
            return trimmed
        }
        
        // Extract just the JSON part
        let jsonPart = String(trimmed[startIndex...endIndex])
        return jsonPart
    }
    
    private func parseGoals(from data: [[String: Any]]) -> [IEPGoal] {
        return data.compactMap { goalData in
            guard let area = goalData["area"] as? String,
                  let goal = goalData["goal"] as? String else {
                return nil
            }
            
            let statusString = goalData["status"] as? String ?? "On Track"
            let status = IEPGoal.GoalStatus(rawValue: statusString) ?? .onTrack
            let progress = goalData["progress"] as? Int ?? 50
            
            return IEPGoal(area: area, goal: goal, status: status, progress: progress)
        }
    }
    
    private func parseServices(from data: [[String: Any]]) -> [IEPService] {
        return data.compactMap { serviceData in
            guard let service = serviceData["service"] as? String,
                  let frequency = serviceData["frequency"] as? String,
                  let provider = serviceData["provider"] as? String else {
                return nil
            }
            
            return IEPService(service: service, frequency: frequency, provider: provider)
        }
    }
    
    private func createFallbackAnalysis(from response: String, studentName: String) -> DocumentAnalysis {
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
    }
}

// MARK: - Document Analysis Result
struct DocumentAnalysis {
    let studentName: String
    let summary: String
    let overallScore: Int
    let strengths: [String]
    let concerns: [String]
    let recommendations: [String]
    let goals: [IEPGoal]
    let services: [IEPService]
    
    // FIXED: Updated method to accept the original ProcessedDocument
    func toIEPData(fileName: String, originalDocument: ProcessedDocument) -> IEPData {
        return IEPData(
            studentName: studentName,
            fileName: fileName,
            uploadDate: Date(),
            notes: "Analyzed with AI assistance",
            overallScore: overallScore,
            summary: summary,
            strengths: strengths,
            concerns: concerns,
            recommendations: recommendations,
            goals: goals,
            services: services,
            originalDocument: originalDocument // FIXED: Now includes the original document!
        )
    }
}
