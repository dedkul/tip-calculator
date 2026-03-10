//
//  ContentView.swift
//  first-app
//
//  Created by Ashish Jangra on 7/3/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var billAmountText: String = ""
    @State private var selectedTipPercent: Int? = nil
    @State private var customTipPercentText: String = ""
    @State private var numberOfPeople: Int = 1

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var billAmount: Double {
        parseBillAmount(billAmountText) ?? 0
    }

    private var effectiveTipPercent: Int {
        if let custom = Int(customTipPercentText), (0...100).contains(custom) {
            return custom
        }
        return selectedTipPercent ?? 0
    }

    private var tipAmount: Double {
        billAmount * (Double(effectiveTipPercent) / 100.0)
    }

    private var totalAmount: Double {
        billAmount + tipAmount
    }

    private var perPersonAmount: Double {
        guard numberOfPeople > 0 else { return 0 }
        return totalAmount / Double(numberOfPeople)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tip Calculator")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                GroupBox("Bill Amount") {
                    TextField("Enter bill amount", text: $billAmountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                GroupBox("Tip Percentage") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick pick:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            tipButton(15)
                            tipButton(18)
                            tipButton(20)
                        }

                        TextField("Custom tip % (0–100)", text: $customTipPercentText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: customTipPercentText) { _, newValue in
                                applyCustomTipInputRules(newValue)
                            }
                    }
                }

                GroupBox("Summary") {
                    VStack(alignment: .leading, spacing: 10) {
                        row(label: "Tip amount") {
                            Text(tipAmount, format: .currency(code: currencyCode))
                                .font(.headline)
                        }
                        row(label: "Total bill") {
                            Text(totalAmount, format: .currency(code: currencyCode))
                                .font(.headline)
                        }
                    }
                }

                GroupBox("Split") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Button {
                                numberOfPeople = max(1, numberOfPeople - 1)
                            } label: {
                                Image(systemName: "minus")
                                    .font(.headline)
                                    .frame(width: 36, height: 36)
                            }
                            .buttonStyle(.bordered)
                            .disabled(numberOfPeople <= 1)

                            Text("People: \(numberOfPeople)")
                                .font(.headline)

                            Button {
                                numberOfPeople += 1
                            } label: {
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .frame(width: 36, height: 36)
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                        }

                        row(label: "Amount per person") {
                            Text(perPersonAmount, format: .currency(code: currencyCode))
                                .font(.headline)
                        }
                    }
                }

                Button("Reset") {
                    reset()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
            }
            .padding()
        }
    }

    private func placeholderField(text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.separator), lineWidth: 1)
            )
    }

    private func placeholderRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }

    private func row<Trailing: View>(
        label: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            trailing()
        }
    }

    private func tipButton(_ percent: Int) -> some View {
        let isSelected = selectedTipPercent == percent

        return Button("\(percent)%") {
            selectedTipPercent = percent
            customTipPercentText = ""
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? .accentColor : .secondary)
    }

    // (placeholderIconButton removed in B-007)

    private func applyCustomTipInputRules(_ raw: String) {
        let digitsOnly = raw.filter(\.isNumber)
        if digitsOnly != raw {
            customTipPercentText = digitsOnly
            return
        }

        guard !digitsOnly.isEmpty else {
            return
        }

        let clamped = min(100, max(0, Int(digitsOnly) ?? 0))
        let clampedText = String(clamped)
        if clampedText != customTipPercentText {
            customTipPercentText = clampedText
            return
        }

        selectedTipPercent = nil
    }

    private func reset() {
        billAmountText = ""
        selectedTipPercent = nil
        customTipPercentText = ""
        numberOfPeople = 1
    }

    private func parseBillAmount(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current

        // Try direct parse first (respects current locale separators).
        if let n = formatter.number(from: trimmed) {
            return n.doubleValue
        }

        // If user typed currency symbols or grouping, strip common non-numeric chars
        // while keeping locale decimal/grouping separators.
        let decimalSep = formatter.decimalSeparator ?? "."
        let groupingSep = formatter.groupingSeparator ?? ","

        let allowed = CharacterSet.decimalDigits
            .union(CharacterSet(charactersIn: decimalSep))
            .union(CharacterSet(charactersIn: groupingSep))

        let cleanedScalars = trimmed.unicodeScalars.filter { allowed.contains($0) }
        let cleaned = String(String.UnicodeScalarView(cleanedScalars))
        guard !cleaned.isEmpty else { return nil }

        if let n = formatter.number(from: cleaned) {
            return n.doubleValue
        }

        // Fallback: accept "." as decimal separator if locale uses something else.
        if decimalSep != "." {
            let normalized = cleaned.replacingOccurrences(of: ".", with: decimalSep)
            if let n = formatter.number(from: normalized) {
                return n.doubleValue
            }
        }

        return nil
    }
}

#Preview {
    ContentView()
}