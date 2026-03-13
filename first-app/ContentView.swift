//
//  ContentView.swift
//  first-app
//
//  Created by Ashish Jangra on 7/3/2026.
//

import SwiftUI

struct ContentView: View {
    private enum Field {
        case billAmount
        case customTipPercent
    }

    @State private var billAmountText: String = ""
    @State private var selectedTipPercent: Int? = 15
    @State private var customTipPercentText: String = ""
    @State private var numberOfPeople: Int = 1
    @FocusState private var focusedField: Field?

    private let tipOptions = [10, 15, 20, 25]

    private let bgColor = Color(red: 0.961, green: 0.957, blue: 0.937)        // #f5f4ef
    private let accentOrange = Color(red: 0.922, green: 0.302, blue: 0.145)    // #eb4d25
    private let darkPanel = Color(red: 0.102, green: 0.102, blue: 0.102)       // #1a1a1a
    private let textPrimary = Color(red: 0.082, green: 0.082, blue: 0.082)     // #151515
    private let textSecondary = Color(red: 0.557, green: 0.553, blue: 0.541)   // #8e8d8a
    private let borderColor = Color(red: 0.886, green: 0.878, blue: 0.847)     // #e2e0d8
    private let lightText = Color(red: 0.961, green: 0.957, blue: 0.937)       // #f5f4ef
    private let grayText = Color(red: 0.655, green: 0.655, blue: 0.655)        // #a7a7a7
    private let darkSeparator = Color(red: 0.2, green: 0.2, blue: 0.2)         // #333

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
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                bgColor
                    .ignoresSafeArea()
                    .onTapGesture(perform: dismissKeyboard)

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            headerView
                            billAmountSection
                                .padding(.top, 16)
                            tipPercentageSection
                                .padding(.top, 32)
                            splitAmongSection
                                .padding(.top, 32)
                            resetButton
                                .padding(.top, 32)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 280)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: dismissKeyboard)
                    }
                    .scrollDismissesKeyboard(.immediately)

                    Spacer(minLength: 0)
                }

                bottomPanel(bottomSafeArea: proxy.safeAreaInsets.bottom)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: dismissKeyboard)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 8) {
            Text("✱")
                .font(.system(size: 20))
                .foregroundColor(accentOrange)

            Text("TipCalc")
                .font(.system(size: 14, weight: .medium))
                .tracking(-0.5)
                .foregroundColor(textPrimary)
        }
        .padding(.vertical, 24)
    }

    // MARK: - Bill Amount

    private var billAmountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("BILL AMOUNT")

            HStack(alignment: .top, spacing: 4) {
                Text("$")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(textSecondary)

                TextField("0", text: $billAmountText)
                    .font(.system(size: 64, weight: .regular))
                    .tracking(-2)
                    .foregroundColor(billAmountText.isEmpty ? textPrimary.opacity(0.5) : textPrimary)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .minimumScaleFactor(0.5)
                    .focused($focusedField, equals: .billAmount)
            }

            separator
        }
    }

    // MARK: - Tip Percentage

    private var tipPercentageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("TIP PERCENTAGE")

            HStack(spacing: 12) {
                ForEach(tipOptions, id: \.self) { percent in
                    tipPillButton(percent)
                }
            }

            customTipField

            separator
        }
    }

    private func tipPillButton(_ percent: Int) -> some View {
        let isSelected = selectedTipPercent == percent && customTipPercentText.isEmpty

        return Button {
            dismissKeyboard()
            selectedTipPercent = percent
            customTipPercentText = ""
        } label: {
            Text("\(percent)%")
                .font(.system(size: 14, weight: .medium))
                .tracking(-0.2)
                .foregroundColor(isSelected ? .white : textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(isSelected ? accentOrange : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? accentOrange : borderColor, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }

    private var customTipField: some View {
        ZStack {
            if customTipPercentText.isEmpty {
                Text("Custom %")
                    .font(.system(size: 14, weight: .medium))
                    .tracking(-0.2)
                    .foregroundColor(textPrimary.opacity(0.5))
            }

            TextField("", text: $customTipPercentText)
                .font(.system(size: 14, weight: .medium))
                .tracking(-0.2)
                .foregroundColor(textPrimary)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textFieldStyle(.plain)
                .focused($focusedField, equals: .customTipPercent)
                .onChange(of: customTipPercentText) { _, newValue in
                    applyCustomTipInputRules(newValue)
                }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 24)
        .overlay(
            Capsule()
                .stroke(borderColor, lineWidth: 0.5)
        )
    }

    // MARK: - Split Among

    private var splitAmongSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("SPLIT AMONG")

            HStack {
                Text("\(numberOfPeople)")
                    .font(.system(size: 32, weight: .medium))
                    .tracking(-0.2)
                    .foregroundColor(textPrimary)

                Spacer()

                HStack(spacing: 12) {
                    circleButton(systemName: "minus", disabled: numberOfPeople <= 1) {
                        numberOfPeople = max(1, numberOfPeople - 1)
                    }

                    circleButton(systemName: "plus", disabled: false) {
                        numberOfPeople += 1
                    }
                }
            }

            separator
        }
    }

    private func circleButton(systemName: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            dismissKeyboard()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(disabled ? textSecondary.opacity(0.3) : textSecondary)
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.3 : 1)
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button {
            dismissKeyboard()
            reset()
        } label: {
            Text("RESET")
                .font(.system(size: 13, weight: .medium))
                .tracking(0.7)
                .foregroundColor(textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Panel

    private func bottomPanel(bottomSafeArea: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(lightText)
                    Text("per person")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(grayText)
                }

                Spacer()

                Text(formatCurrency(perPersonAmount))
                    .font(.system(size: 48, weight: .regular))
                    .tracking(-2)
                    .foregroundColor(accentOrange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.bottom, 1)
            .overlay(
                darkSeparator.frame(height: 1),
                alignment: .bottom
            )

            VStack(spacing: 16) {
                summaryRow(label: "Total Bill", value: formatCurrency(totalAmount))
                summaryRow(label: "Total Tip", value: formatCurrency(tipAmount))
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(alignment: .bottom) {
            darkPanel
                .frame(height: bottomSafeArea)
                .offset(y: bottomSafeArea)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32
            )
            .fill(darkPanel)
        )
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(grayText)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(lightText)
        }
    }

    // MARK: - Shared Components

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.6)
            .foregroundColor(textSecondary)
    }

    private var separator: some View {
        borderColor.frame(height: 1)
    }

    // MARK: - Helpers

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

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
        selectedTipPercent = 15
        customTipPercentText = ""
        numberOfPeople = 1
    }

    private func parseBillAmount(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current

        if let n = formatter.number(from: trimmed) {
            return n.doubleValue
        }

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
