import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var draftCode: String
    @State private var savedCode: String
    @State private var didSave = false

    private var normalizedCode: String {
        CarrierCode.normalize(draftCode)
    }

    private var isValid: Bool {
        CarrierCode.isValid(normalizedCode)
    }

    init() {
        let settings = CarrierStore.load()
        _draftCode = State(initialValue: settings.carrierCode)
        _savedCode = State(initialValue: settings.carrierCode)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    barcodePreview
                    carrierForm
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("載具條碼")
        }
    }

    private var barcodePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(savedCode.isEmpty ? "尚未儲存載具" : savedCode)
                .font(.system(.title3, design: .monospaced, weight: .semibold))
                .foregroundStyle(savedCode.isEmpty ? .secondary : .primary)

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white)

                if CarrierCode.isValid(savedCode) {
                    VStack(spacing: 10) {
                        Code39BarcodeView(value: savedCode)
                            .frame(height: 88)
                        Text(savedCode)
                            .font(.system(.callout, design: .monospaced, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    .padding(16)
                } else {
                    Text("儲存後會顯示條碼")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 144)
            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 8)
        }
    }

    private var carrierForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("手機發票載具號碼")
                .font(.headline)

            TextField("/AB12+CD", text: $draftCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .font(.system(.title3, design: .monospaced, weight: .semibold))
                .textFieldStyle(.roundedBorder)
                .onChange(of: draftCode) { _, newValue in
                    draftCode = CarrierCode.normalize(newValue)
                    didSave = false
                }

            Label(
                isValid ? "格式正確" : CarrierCode.validationMessage(for: draftCode),
                systemImage: isValid ? "checkmark.circle.fill" : "exclamationmark.circle"
            )
            .font(.callout)
            .foregroundStyle(isValid ? .green : .secondary)

            Button {
                saveCarrier()
            } label: {
                Label(didSave ? "已儲存" : "儲存載具", systemImage: didSave ? "checkmark" : "tray.and.arrow.down")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValid)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
    }

    private func saveCarrier() {
        guard let carrierCode = CarrierCode(normalizedCode) else {
            return
        }

        let settings = CarrierSettings(carrierCode: carrierCode.value)
        CarrierStore.save(settings)
        savedCode = carrierCode.value
        didSave = true
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    ContentView()
}
