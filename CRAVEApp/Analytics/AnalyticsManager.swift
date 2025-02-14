// File: AnalyticsManager.swift
// Purpose: Central manager for all analytics operations and data processing

import Foundation
import SwiftData
import Combine

@MainActor
final class AnalyticsManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentAnalytics: AnalyticsSnapshot?
    @Published private(set) var processingState: ProcessingState = .idle
    @Published private(set) var lastUpdateTime: Date?
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    private let analyticsStorage: AnalyticsStorage
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Analytics Processors
    private let frequencyAnalyzer: FrequencyAnalyzer
    private let patternAnalyzer: PatternAnalyzer
    private let insightGenerator: InsightGenerator
    private let predictionEngine: PredictionEngine
    
    init(modelContext: ModelContext, storage: AnalyticsStorage) {
        self.modelContext = modelContext
        self.analyticsStorage = storage
        self.frequencyAnalyzer = FrequencyAnalyzer()
        self.patternAnalyzer = PatternAnalyzer()
        self.insightGenerator = InsightGenerator()
        self.predictionEngine = PredictionEngine()
        
        setupObservers()
    }
    
    // MARK: - Public Interface
    func processNewCraving(_ craving: CravingModel) async throws {
        processingState = .processing
        
        do {
            // 1. Persist the new craving
            modelContext.insert(craving)
            try modelContext.save()
            
            // 2. Update analytics
            let analytics = try await createAnalytics(for: craving)
            try await analyticsStorage.store(analytics)
            
            // 3. Trigger aggregation and analysis
            try await analyzeData()
            
            processingState = .idle
            lastUpdateTime = Date()
        } catch {
            processingState = .error
            throw error
        }
    }
    
    
    
    // MARK: - Analytics Processing
    private func createAnalytics(for craving: CravingModel) async throws -> CravingAnalytics {
        // Extract data from CravingModel and create CravingAnalytics
        let analytics = CravingAnalytics(
            id: craving.id,
            timestamp: craving.timestamp,
            intensity: craving.intensity,
            triggers: craving.triggers,
            metadata: [:] // Add relevant metadata
        )
        
        return analytics
    }
    
    
    
    private func analyzeData() async throws {
        // Fetch data
        let timeRange = DateInterval(start: Date().addingTimeInterval(-30*24*60*60), end: Date())
        let analyticsData = try await analyticsStorage.fetchRange(timeRange)
        
        // Perform frequency analysis
        // let frequencyResults = frequencyAnalyzer.analyze(analyticsData) // Not used
        
        // Perform pattern analysis
        // let patternResults = patternAnalyzer.analyze(analyticsData)
        
        // Generate insights
        let insights = insightGenerator.generateInsights(from: analyticsData)
        // Generate predictions
        let predictions = try predictionEngine.generatePrediction(from: analyticsData)
        // Update current analytics snapshot
        currentAnalytics = AnalyticsSnapshot(
            timestamp: Date(),
            insights: insights,
            predictions: [predictions]
        )
    }
    
    
    
    // MARK: - Data Retrieval
    func getBasicStats() async -> BasicAnalyticsResult? {
        do {
            let cravings = try modelContext.fetch(FetchDescriptor<CravingModel>())
            
            let frequencyQuery = FrequencyQuery()
            let cravingsByFrequency = frequencyQuery.cravingsPerDay(using: cravings)
            
            let calendarViewQuery = CalendarViewQuery()
            let cravingsPerDay = calendarViewQuery.cravingsPerDay(using: cravings)
            
            let timeOfDayQuery = TimeOfDayQuery()
            let cravingsByTimeSlot = timeOfDayQuery.cravingsByTimeSlot(using: cravings)
            
            return BasicAnalyticsResult(
                cravingsByFrequency: cravingsByFrequency,
                cravingsPerDay: cravingsPerDay,
                cravingsByTimeSlot: cravingsByTimeSlot
            )
        } catch {
            print("Error fetching basic stats: \(error)")
            return nil
        }
    }
    
    func generateInsights(from analytics: [CravingAnalytics]) async throws -> [AnalyticsInsight] {
        return insightGenerator.generateInsights(from: analytics)
        
    }
    
    func generatePredictions() async throws -> [AnalyticsPrediction] {
        // Fetch the last 30 days of data.
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        let timeRange = DateInterval(start: thirtyDaysAgo, end: Date())
        let analyticsData = try await analyticsStorage.fetchRange(timeRange)
        let prediction = try predictionEngine.generatePrediction(from: analyticsData)
        return [prediction]
    }
    
    // MARK: - Setup
    private func setupObservers() {
        // Subscribe to relevant notifications, e.g., new craving entries
        // This allows the manager to react to data changes
    }
    
    
    
    
    
    // MARK: - Internal Types
    enum ProcessingState {
        case idle
        case processing
        case error
    }
    
    struct AnalyticsSnapshot {
        let timestamp: Date
        let insights: [AnalyticsInsight]
        let predictions: [AnalyticsPrediction]
        // Add other snapshot data as needed
    }
}

