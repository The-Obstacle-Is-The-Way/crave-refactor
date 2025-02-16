//
//
// CRAVEApp/Analytics/AnalyticsTypes.swift
//
//

import Foundation

// MARK: - Reporting Types

public enum ReportGenerationState: String, Codable {
    case idle
    case generating
    case completed
    case error
}

public enum ReportType: String, CaseIterable, Codable {
    case summary = "Summary"
    case detailed = "Detailed"
    case trend = "Trend"
}

public enum ReportFormat: String, CaseIterable, Codable {
    case pdf = "PDF"
    case csv = "CSV"
    case json = "JSON"
}

public struct Report: Codable {
    let metadata: ReportMetadata
    let data: ReportData
    let format: ReportFormat
    let generationDate: Date
    let state: ReportGenerationState
}

public struct ReportMetadata: Codable {
    let reportType: ReportType
    let format: ReportFormat
    let creationDate: Date
}

public struct ReportData: Codable {
    let title: String
    let content: String
}
