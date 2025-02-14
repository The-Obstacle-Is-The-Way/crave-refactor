// File: AnalyticsFormatter.swift
// Purpose: Handles all formatting and data transformation for analytics data presentation

import Foundation
import SwiftUI
import Charts

@MainActor
final class AnalyticsFormatter {
    // MARK: - Shared Instance
    static let shared = AnalyticsFormatter()
    
    // MARK: - Formatters
    private let dateFormatter: DateFormatter
    private let numberFormatter: NumberFormatter
    private let durationFormatter: DateComponentsFormatter
    private let percentageFormatter: NumberFormatter
    private let timeIntervalFormatter: DateComponentsFormatter
    
    // MARK: - Configuration
    private let configuration: AnalyticsConfiguration
    private let locale: Locale
    private let calendar: Calendar
    private let timeZone: TimeZone
    
    // MARK: - Initialization
    init(
        configuration: AnalyticsConfiguration = .shared,
        locale: Locale = .current,
        calendar: Calendar = .current,
        timeZone: TimeZone = .current
    ) {
        self.configuration = configuration
        self.locale = locale
        self.calendar = calendar
        self.timeZone = timeZone
        
        // Initialize formatters
        self.dateFormatter = DateFormatter()
        self.numberFormatter = NumberFormatter()
        self.durationFormatter = DateComponentsFormatter()
        self.percentageFormatter = NumberFormatter()
        self.timeIntervalFormatter = DateComponentsFormatter()
        
        setupFormatters()
    }
    
    // MARK: - Public Formatting Methods
    func formatDate(_ date: Date, style: DateFormatStyle = .medium) -> String {
        dateFormatter.dateStyle = style.dateFormatterStyle
        return dateFormatter.string(from: date)
    }
    
    func formatTime(_ date: Date, style: TimeFormatStyle = .short) -> String {
        dateFormatter.timeStyle = style.timeFormatterStyle
        return dateFormatter.string(from: date)
    }
    
    func formatDateTime(_ date: Date, dateStyle: DateFormatStyle = .medium, timeStyle: TimeFormatStyle = .short) -> String {
        dateFormatter.dateStyle = dateStyle.dateFormatterStyle
        dateFormatter.timeStyle = timeStyle.timeFormatterStyle
        return dateFormatter.string(from: date)
    }
    
    func formatNumber(_ number: Double, style: NumberFormatStyle = .decimal) -> String {
        numberFormatter.numberStyle = style.numberFormatterStyle
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    func formatPercentage(_ value: Double) -> String {
        percentageFormatter.string(from: NSNumber(value: value)) ?? "\(value)%"
    }
    
    func formatDuration(_ interval: TimeInterval) -> String {
        durationFormatter.string(from: interval) ?? "\(interval)"
    }
    
    func formatTimeInterval(_ interval: TimeInterval, units: NSCalendar.Unit = [.hour, .minute]) -> String {
        timeIntervalFormatter.allowedUnits = units
        return timeIntervalFormatter.string(from: interval) ?? "\(interval)"
    }
    
    // MARK: - Analytics Specific Formatting
    func formatCravingIntensity(_ intensity: Int) -> String {
        return "\(intensity)/10"
    }
    
    func formatFrequency(_ count: Int, timeFrame: TimeFrame) -> String {
        switch timeFrame {
        case .daily:
            return "\(count) per day"
        case .weekly:
            return "\(count) per week"
        case .monthly:
            return "\(count) per month"
        }
    }
    
    func formatPattern(_ pattern: DetectedPattern) -> FormattedPattern {
        return FormattedPattern(
            title: formatPatternTitle(pattern),
            description: formatPatternDescription(pattern),
            frequency: formatPatternFrequency(pattern),
            strength: formatPatternStrength(pattern.strength)
        )
    }
    
    func formatInsight(_ insight: AnalyticsInsight) -> FormattedInsight {
        return FormattedInsight(
            title: insight.title,
            description: insight.description,
            confidence: formatPercentage(insight.confidence),
            recommendations: insight.recommendations.map(formatRecommendation)
        )
    }
    
    // MARK: - Chart Data Formatting
    func formatChartData(_ data: [ChartDataPoint]) -> [FormattedChartPoint] {
        return data.map { point in
            FormattedChartPoint(
                label: formatChartLabel(point),
                value: formatChartValue(point),
                color: colorForValue(point.value)
            )
        }
    }
    
    func formatAxisLabel(_ value: Double, axis: ChartAxis) -> String {
        switch axis {
        case .x:
            return formatNumber(value, style: .decimal)
        case .y:
            return formatNumber(value, style: .decimal)
        }
    }
    
    // MARK: - Private Methods
    private func setupFormatters() {
        // Date Formatter
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = timeZone
        
        // Number Formatter
        numberFormatter.locale = locale
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        
        // Percentage Formatter
        percentageFormatter.numberStyle = .percent
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 1
        
        // Duration Formatter
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute, .second]
        
        // Time Interval Formatter
        timeIntervalFormatter.unitsStyle = .short
        timeIntervalFormatter.allowedUnits = [.hour, .minute]
    }
    
    private func formatPatternTitle(_ pattern: DetectedPattern) -> String {
        switch pattern.type {
        case .time:
            return "Time-based Pattern"
        case .behavior:
            return "Behavioral Pattern"
        case .context:
            return "Contextual Pattern"
        }
    }
    
    private func formatPatternDescription(_ pattern: DetectedPattern) -> String {
        // Implement pattern-specific description formatting
        return pattern.description
    }
    
    private func formatPatternFrequency(_ pattern: DetectedPattern) -> String {
        return formatFrequency(
            Int(pattern.frequency),
            timeFrame: .weekly
        )
    }
    
    private func formatPatternStrength(_ strength: Double) -> String {
        return formatPercentage(strength)
    }
    
    private func formatRecommendation(_ recommendation: String) -> String {
        // Implement recommendation formatting
        return recommendation
    }
    
    private func formatChartLabel(_ point: ChartDataPoint) -> String {
        switch point.labelType {
        case .date:
            return formatDate(point.date)
        case .time:
            return formatTime(point.date)
        case .value:
            return formatNumber(point.value)
        }
    }
    
    private func formatChartValue(_ point: ChartDataPoint) -> String {
        return formatNumber(point.value)
    }
    
    private func colorForValue(_ value: Double) -> Color {
        // Implement color scaling based on value
        return .blue
    }
}
