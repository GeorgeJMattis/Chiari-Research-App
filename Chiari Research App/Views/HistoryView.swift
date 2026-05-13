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
                    ContentUnavailableView(
                        "Couldn't load data",
                        systemImage: "exclamationmark.triangle",
                        description: Text(err)
                    )
                } else if historyViewModel.surveySessions.isEmpty && historyViewModel.sensorBatches.isEmpty {
                    ContentUnavailableView(
                        "No data yet",
                        systemImage: "chart.xyaxis.line",
                        description: Text("Complete surveys and take measurements to see your history.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            chartSection
                            legendSection
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
            .onChange(of: historyViewModel.range) {
                Task { await historyViewModel.load(uid: uid) }
            }
        }
    }

    // MARK: - Dual-layer Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Headache Severity & Pressure")
                .font(.headline)

            Chart {
                // Averaged pressure per batch — smooth curve throughout the day
                ForEach(historyViewModel.sensorBatches, id: \.id) { batch in
                    if let time = batch.startTimeStamp, let avg = averagePressure(batch) {
                        LineMark(
                            x: .value("Time", time),
                            y: .value("Pressure (kPa)", avg)
                        )
                        .foregroundStyle(.blue.opacity(0.6))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Time", time),
                            y: .value("Pressure (kPa)", avg)
                        )
                        .foregroundStyle(.blue.opacity(0.4))
                        .symbolSize(25)
                    }
                }

                // Headache severity per survey — overlaid on same x-axis
                ForEach(headacheSessions, id: \.id) { session in
                    if let responses = session.responses, let time = scheduledTime(session) {
                        PointMark(
                            x: .value("Time", time),
                            y: .value("Pain (1–10)", responses.painLevel)
                        )
                        .foregroundStyle(.red)
                        .symbolSize(60)
                        .annotation(position: .top, spacing: 4) {
                            Text(String(format: "%.0f", responses.painLevel))
                                .font(.system(size: 9))
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel("\(value.index == 0 ? "" : "\(value.as(Double.self).map { Int($0) } ?? 0)")")
                }
            }
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Legend

    private var legendSection: some View {
        HStack(spacing: 20) {
            Label("Pressure (kPa)", systemImage: "circle.fill")
                .foregroundStyle(.blue.opacity(0.6))
                .font(.caption)
            Label("Headache severity", systemImage: "circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Session List

    private var sessionListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Check-ins")
                .font(.headline)

            ForEach(historyViewModel.surveySessions.reversed()) { session in
                if let responses = session.responses {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.slot.displayName)
                                .font(.subheadline).bold()
                            Text(session.scheduledDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(responses.hadHeadache ? "Headache" : "No headache")
                                .font(.caption)
                                .foregroundStyle(responses.hadHeadache ? .red : .green)
                            if responses.hadHeadache {
                                Text("Pain: \(Int(responses.painLevel))/10")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    Divider()
                }
            }
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Helpers

    private func averagePressure(_ batch: SensorBatch) -> Double? {
        let values = batch.readings.compactMap { $0.value["pressure"] }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private var headacheSessions: [SurveySession] {
        historyViewModel.surveySessions.filter { $0.responses?.hadHeadache == true }
    }

    private func scheduledTime(_ session: SurveySession) -> Date? {
        Calendar.current.date(
            bySettingHour: session.slot.hour,
            minute: 0, second: 0,
            of: session.scheduledDate
        )
    }
}

#Preview {
    HistoryView(historyViewModel: HistoryViewModel(), uid: "preview")
}

