//
//  HistoryView.swift
//  Chiari Research App
//

import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    let uid: String

    var body: some View {
        NavigationStack {
            Group {
                if historyViewModel.isLoading {
                    ProgressView("Loading data…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let err = historyViewModel.errorMessage {
                    emptyStateView(
                        title: "Couldn't load data",
                        systemImage: "exclamationmark.triangle",
                        description: err
                    )
                } else if historyViewModel.surveySessions.isEmpty && historyViewModel.sensorBatches.isEmpty {
                    emptyStateView(
                        title: "No data yet",
                        systemImage: "chart.xyaxis.line",
                        description: "Complete surveys and take measurements to see your history."
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            symptomChartSection
                            moodChartSection
                            pressureChartSection
                            sessionListSection
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Range", selection: $historyViewModel.range) {
                        ForEach(HistoryViewModel.Range.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
            }
            .task { await historyViewModel.load(uid: uid) }
            .onChange(of: historyViewModel.range) { _ in
                Task { await historyViewModel.load(uid: uid) }
            }
        }
    }

    private func emptyStateView(title: String, systemImage: String, description: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    /// Space x-axis labels out on the 30-day range so days don't overcrowd.
    private var xAxisStride: Int {
        switch historyViewModel.range {
        case .week:  return 1
        case .month: return 5
        }
    }

    // MARK: - Symptoms Chart (headache, balance, numbness), 0–10

    private var symptomChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Symptoms")
                .font(.headline)

            Chart(symptomPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Severity", point.value)
                )
                .foregroundStyle(by: .value("Metric", point.metric))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Severity", point.value)
                )
                .foregroundStyle(by: .value("Metric", point.metric))
                .symbolSize(28)
            }
            .chartForegroundStyleScale([
                "Headache": Color.red,
                "Balance": Color.orange,
                "Numbness/Tingling": Color.purple
            ])
            .chartYScale(domain: 0...10)
            .frame(height: 220)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: xAxisStride)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartLegend(position: .bottom)
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Mood Chart (cheerful, sad, anxious), 0–10

    private var moodChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood")
                .font(.headline)

            Chart(moodPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Rating", point.value)
                )
                .foregroundStyle(by: .value("Mood", point.metric))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Rating", point.value)
                )
                .foregroundStyle(by: .value("Mood", point.metric))
                .symbolSize(28)
            }
            .chartForegroundStyleScale([
                "Cheerful": Color.green,
                "Sad": Color.blue,
                "Anxious": Color.pink
            ])
            .chartYScale(domain: 0...10)
            .frame(height: 220)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: xAxisStride)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartLegend(position: .bottom)
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Pressure Chart (own auto-scaled axis)

    private var pressureChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pressure")
                .font(.headline)

            Chart {
                ForEach(historyViewModel.sensorBatches, id: \.id) { batch in
                    if let time = batch.startTimeStamp, let avg = averagePressure(batch) {
                        LineMark(
                            x: .value("Time", time),
                            y: .value("Pressure", avg)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Time", time),
                            y: .value("Pressure", avg)
                        )
                        .foregroundStyle(.blue.opacity(0.5))
                        .symbolSize(25)
                    }
                }
            }
            // Fit the y-axis to the data range instead of forcing zero, so the
            // small day-to-day pressure variation is readable.
            .chartYScale(domain: .automatic(includesZero: false))
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: xAxisStride)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Session List

    private var sessionListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Check-ins")
                .font(.headline)

            ForEach(historyViewModel.surveySessions.reversed()) { session in
                if let r = session.responses {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(session.slot.displayName)
                                .font(.subheadline).bold()
                            Spacer()
                            Text(session.scheduledDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption).foregroundStyle(.secondary)
                        }

                        metricLine(label: "Headache", had: r.hadHeadache, value: r.painLevel)
                        metricLine(label: "Balance", had: r.hadBalanceProblem, value: r.balance)
                        metricLine(label: "Numbness/Tingling", had: r.hadNumbness, value: r.numbnessTingling)

                        HStack(spacing: 14) {
                            Text("Cheerful \(Int(r.cheerful))")
                            Text("Sad \(Int(r.sad))")
                            Text("Anxious \(Int(r.anxious))")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    Divider()
                }
            }
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    /// One symptom row in a check-in card: "None" when not reported, else "N/10".
    private func metricLine(label: String, had: Bool, value: Double) -> some View {
        HStack {
            Text(label).font(.caption)
            Spacer()
            Text(had ? "\(Int(value))/10" : "None")
                .font(.caption)
                .foregroundStyle(had ? .red : .green)
        }
    }

    // MARK: - Chart data

    /// Symptom values per check-in. Anything not reported that day plots as 0
    /// so each line stays continuous.
    private var symptomPoints: [MetricPoint] {
        historyViewModel.surveySessions.flatMap { session -> [MetricPoint] in
            guard let r = session.responses, let time = scheduledTime(session) else { return [] }
            return [
                MetricPoint(date: time, metric: "Headache", value: r.hadHeadache ? r.painLevel : 0),
                MetricPoint(date: time, metric: "Balance", value: r.hadBalanceProblem ? r.balance : 0),
                MetricPoint(date: time, metric: "Numbness/Tingling", value: r.hadNumbness ? r.numbnessTingling : 0)
            ]
        }
    }

    private var moodPoints: [MetricPoint] {
        historyViewModel.surveySessions.flatMap { session -> [MetricPoint] in
            guard let r = session.responses, let time = scheduledTime(session) else { return [] }
            return [
                MetricPoint(date: time, metric: "Cheerful", value: r.cheerful),
                MetricPoint(date: time, metric: "Sad", value: r.sad),
                MetricPoint(date: time, metric: "Anxious", value: r.anxious)
            ]
        }
    }

    // MARK: - Helpers

    private func averagePressure(_ batch: SensorBatch) -> Double? {
        let values = batch.readings.compactMap { $0.value["pressure"] }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func scheduledTime(_ session: SurveySession) -> Date? {
        Calendar.current.date(
            bySettingHour: session.slot.hour,
            minute: 0, second: 0,
            of: session.scheduledDate
        )
    }
}

/// One plotted point in a metric chart: a metric's value for a given check-in.
private struct MetricPoint: Identifiable {
    let id = UUID()
    let date: Date
    let metric: String
    let value: Double
}

#Preview {
    HistoryView(historyViewModel: HistoryViewModel(), uid: "preview")
}
